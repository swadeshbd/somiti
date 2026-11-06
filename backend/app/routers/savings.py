from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import random

from app.core.database import get_db
from app.models.user import User
from app.models.savings import SavingsAccount
from app.models.transaction import Transaction
from app.schemas.savings import SavingsAccountResponse, SavingsDepositRequest
from app.routers.deps import get_current_user

router = APIRouter(prefix="/savings", tags=["Savings & DPS"])


@router.get("/accounts", response_model=list[SavingsAccountResponse])
def get_savings_accounts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get customer savings and DPS accounts. If none exist, auto-create a default Regular Savings account.
    """
    accounts = db.query(SavingsAccount).filter(SavingsAccount.user_id == current_user.id).all()
    if not accounts:
        # Auto-create welcome regular savings
        default_acc = SavingsAccount(
            account_number=f"SAV-{datetime.now().strftime('%Y%m')}-{random.randint(1000, 9999)}",
            user_id=current_user.id,
            account_type="REGULAR",
            balance=500.0,  # 500 BDT initial welcome/membership deposit
            monthly_installment=0.0,
            interest_rate=6.0,
            status="ACTIVE"
        )
        db.add(default_acc)
        db.commit()
        db.refresh(default_acc)
        accounts = [default_acc]

    return accounts


@router.post("/deposit")
def deposit_savings(
    payload: SavingsDepositRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Deposit money into savings account via bKash/Nagad.
    """
    acc = db.query(SavingsAccount).filter(
        SavingsAccount.id == payload.account_id,
        SavingsAccount.user_id == current_user.id
    ).first()

    if not acc:
        raise HTTPException(status_code=404, detail="Savings account not found")

    simulated_trx_id = f"DEP{datetime.now().strftime('%d%H%M')}{''.join(random.choices('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', k=4))}"

    acc.balance = round(acc.balance + payload.amount, 2)

    trx = Transaction(
        user_id=current_user.id,
        savings_account_id=acc.id,
        transaction_type="SAVINGS_DEPOSIT",
        amount=payload.amount,
        payment_method=payload.payment_method.upper(),
        gateway_trx_id=simulated_trx_id,
        payment_reference=f"Savings deposit to {acc.account_number}",
        status="COMPLETED",
        notes=f"Deposited {payload.amount} BDT via {payload.payment_method.upper()}"
    )
    db.add(trx)
    db.commit()

    return {
        "success": True,
        "message": "সঞ্চয় একাউন্টে টাকা সফলভাবে জমা হয়েছে!",
        "new_balance": acc.balance,
        "transaction_id": simulated_trx_id
    }
