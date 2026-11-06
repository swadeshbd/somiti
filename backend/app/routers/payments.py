from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import uuid
import random

from app.core.database import get_db
from app.models.user import User
from app.models.loan import Loan, Installment, LoanStatus, InstallmentStatus
from app.models.transaction import Transaction
from app.schemas.payment import (
    PayInstallmentRequest,
    PaymentResponse,
    TransactionHistoryResponse
)
from app.routers.deps import get_current_user

router = APIRouter(prefix="/payments", tags=["MFS Payments & Transactions"])


@router.post("/pay-installment", response_model=PaymentResponse)
def pay_installment(
    payload: PayInstallmentRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Pay loan installment using bKash / Nagad / Rocket.
    Simulates tokenized payment verification and updates ledger.
    """
    # 1. Fetch Loan and Installment
    loan = db.query(Loan).filter(
        Loan.id == payload.loan_id,
        Loan.user_id == current_user.id
    ).first()

    if not loan:
        raise HTTPException(status_code=404, detail="Loan account not found")

    installment = db.query(Installment).filter(
        Installment.id == payload.installment_id,
        Installment.loan_id == loan.id
    ).first()

    if not installment:
        raise HTTPException(status_code=404, detail="Installment not found")

    if installment.status == InstallmentStatus.PAID.value:
        raise HTTPException(status_code=400, detail="This installment is already fully paid")

    # 2. Generate simulated MFS Gateway TrxID (e.g., BK-9X82KD71)
    prefix = payload.payment_method.upper()[:2]
    simulated_trx_id = f"{prefix}{datetime.now().strftime('%d%H%M')}{''.join(random.choices('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', k=4))}"

    # 3. Create Transaction Ledger Entry
    trx = Transaction(
        user_id=current_user.id,
        loan_id=loan.id,
        transaction_type="LOAN_INSTALLMENT",
        amount=payload.amount,
        payment_method=payload.payment_method.upper(),
        gateway_trx_id=simulated_trx_id,
        payment_reference=f"Installment #{installment.installment_number} for {loan.account_number}",
        status="COMPLETED",
        notes=f"Paid via {payload.payment_method.upper()} from {payload.customer_phone}"
    )
    db.add(trx)

    # 4. Update Installment
    installment.status = InstallmentStatus.PAID.value
    installment.paid_amount = payload.amount
    installment.paid_date = datetime.utcnow()
    installment.transaction_id = simulated_trx_id

    # 5. Update Loan Balances
    loan.total_paid = round(loan.total_paid + payload.amount, 2)
    loan.total_outstanding = max(0.0, round(loan.total_outstanding - payload.amount, 2))
    loan.paid_installments_count += 1

    # Check if all installments are completed
    if loan.paid_installments_count >= loan.total_installments or loan.total_outstanding <= 0:
        loan.status = LoanStatus.COMPLETED.value

    db.commit()

    return PaymentResponse(
        success=True,
        transaction_id=trx.id,
        gateway_trx_id=simulated_trx_id,
        amount=payload.amount,
        payment_method=payload.payment_method.upper(),
        loan_id=loan.id,
        installment_id=installment.id,
        message=f"কিস্তি #{installment.installment_number} সফলভাবে পরিশোধিত হয়েছে!",
        timestamp=trx.created_at
    )


@router.get("/history", response_model=list[TransactionHistoryResponse])
def get_transaction_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get customer digital passbook / transaction statement.
    """
    history = db.query(Transaction).filter(
        Transaction.user_id == current_user.id
    ).order_by(Transaction.created_at.desc()).all()
    return history
