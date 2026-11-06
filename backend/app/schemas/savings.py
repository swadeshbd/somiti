from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class SavingsAccountResponse(BaseModel):
    id: str
    account_number: str
    account_type: str
    balance: float
    monthly_installment: float
    interest_rate: float
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class SavingsDepositRequest(BaseModel):
    account_id: str
    amount: float
    payment_method: str = "BKASH"
