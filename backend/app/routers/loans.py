from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import date, datetime
import random

from app.core.database import get_db
from app.models.user import User
from app.models.loan import (
    LoanProduct,
    LoanApplication,
    Loan,
    Installment,
    ApplicationStatus,
    LoanStatus,
    InstallmentStatus
)
from app.schemas.loan import (
    LoanProductResponse,
    LoanCalculationRequest,
    LoanCalculationResponse,
    LoanApplyRequest,
    LoanApplicationResponse,
    LoanResponse,
    InstallmentResponse
)
from app.services.calculator import MicrocreditCalculator
from app.routers.deps import get_current_user

router = APIRouter(prefix="/loans", tags=["Loans & Installments"])


@router.get("/products", response_model=List[LoanProductResponse])
def get_loan_products(db: Session = Depends(get_db)):
    """
    List all active microcredit loan schemes (ক্ষুদ্রঋণ প্যাকেজসমূহ).
    """
    products = db.query(LoanProduct).all()
    return products


@router.post("/calculate", response_model=LoanCalculationResponse)
def calculate_loan_schedule(payload: LoanCalculationRequest):
    """
    Simulate installment schedule (Flat or Declining Balance).
    """
    if payload.calculation_type.upper() == "DECLINING":
        calc_result = MicrocreditCalculator.calculate_declining_balance(
            principal=payload.principal,
            annual_rate_pct=payload.interest_rate,
            tenure_weeks=payload.tenure_weeks
        )
    else:
        calc_result = MicrocreditCalculator.calculate_flat_rate(
            principal=payload.principal,
            annual_rate_pct=payload.interest_rate,
            tenure_weeks=payload.tenure_weeks
        )
    return calc_result


@router.post("/apply", response_model=LoanApplicationResponse)
def apply_for_loan(
    payload: LoanApplyRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Borrower submits a new microcredit loan application.
    """
    product = db.query(LoanProduct).filter(LoanProduct.id == payload.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Loan product not found")

    if payload.requested_amount < product.min_amount or payload.requested_amount > product.max_amount:
        raise HTTPException(
            status_code=400,
            detail=f"Amount must be between ৳{product.min_amount:,.0f} and ৳{product.max_amount:,.0f}"
        )

    # Check if borrower already has an active loan
    existing_active = db.query(Loan).filter(
        Loan.user_id == current_user.id,
        Loan.status == LoanStatus.ACTIVE.value
    ).first()

    if existing_active:
        raise HTTPException(
            status_code=400,
            detail="You already have an active loan. Please repay before applying for a new one."
        )

    application = LoanApplication(
        user_id=current_user.id,
        product_id=product.id,
        requested_amount=payload.requested_amount,
        tenure_weeks=payload.tenure_weeks,
        purpose=payload.purpose,
        guarantor_name=payload.guarantor_name,
        guarantor_phone=payload.guarantor_phone,
        guarantor_nid=payload.guarantor_nid,
        guarantor_relation=payload.guarantor_relation,
        status=ApplicationStatus.SUBMITTED.value
    )
    db.add(application)
    db.commit()
    db.refresh(application)
    return application


@router.get("/applications", response_model=List[LoanApplicationResponse])
def get_my_applications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    List all loan applications submitted by current borrower.
    """
    apps = db.query(LoanApplication).filter(LoanApplication.user_id == current_user.id).order_by(LoanApplication.created_at.desc()).all()
    return apps


@router.post("/applications/{application_id}/approve-and-disburse", response_model=LoanResponse)
def approve_and_disburse_loan(
    application_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Helper endpoint for testing/demo: Approves the pending application and disburses
    the loan immediately with complete weekly installment schedule.
    """
    application = db.query(LoanApplication).filter(
        LoanApplication.id == application_id,
        LoanApplication.user_id == current_user.id
    ).first()

    if not application:
        raise HTTPException(status_code=404, detail="Application not found")

    if application.status == ApplicationStatus.DISBURSED.value:
        raise HTTPException(status_code=400, detail="Loan is already disbursed")

    product = application.product
    
    # Calculate installment schedule
    calc = MicrocreditCalculator.calculate_flat_rate(
        principal=application.requested_amount,
        annual_rate_pct=product.interest_rate,
        tenure_weeks=application.tenure_weeks
    )

    acc_num = f"LN-{datetime.now().strftime('%Y%m')}-{random.randint(1000, 9999)}"

    new_loan = Loan(
        account_number=acc_num,
        user_id=current_user.id,
        application_id=application.id,
        product_id=product.id,
        principal_amount=calc["principal"],
        interest_rate=calc["annual_rate_pct"],
        interest_amount=calc["total_interest"],
        total_payable=calc["total_payable"],
        total_paid=0.0,
        total_outstanding=calc["total_payable"],
        tenure_weeks=calc["tenure_weeks"],
        total_installments=len(calc["schedule"]),
        paid_installments_count=0,
        installment_amount=calc["installment_amount"],
        status=LoanStatus.ACTIVE.value,
        disbursement_date=date.today()
    )
    db.add(new_loan)
    db.flush()

    # Generate Installment records
    for item in calc["schedule"]:
        installment = Installment(
            loan_id=new_loan.id,
            installment_number=item["installment_number"],
            amount=item["amount"],
            principal_component=item["principal_component"],
            interest_component=item["interest_component"],
            due_date=item["due_date"],
            status=InstallmentStatus.PENDING.value
        )
        db.add(installment)

    application.status = ApplicationStatus.DISBURSED.value
    db.commit()
    db.refresh(new_loan)
    return new_loan


@router.get("/active", response_model=List[LoanResponse])
def get_my_loans(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all active and past loans for current borrower.
    """
    loans = db.query(Loan).filter(Loan.user_id == current_user.id).order_by(Loan.created_at.desc()).all()
    return loans


@router.get("/{loan_id}", response_model=LoanResponse)
def get_loan_details(
    loan_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get full loan details including every installment due date and status.
    """
    loan = db.query(Loan).filter(
        Loan.id == loan_id,
        Loan.user_id == current_user.id
    ).first()

    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    return loan
