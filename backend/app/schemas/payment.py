from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class PayInstallmentRequest(BaseModel):
    loan_id: str
    installment_id: str
    amount: float = Field(..., gt=0)
    payment_method: str = Field(..., example="BKASH")  # BKASH, NAGAD, ROCKET
    customer_phone: str = Field(..., example="01700000000")


class PaymentResponse(BaseModel):
    success: bool
    transaction_id: str
    gateway_trx_id: str
    amount: float
    payment_method: str
    loan_id: str
    installment_id: str
    message: str
    timestamp: datetime


class TransactionHistoryResponse(BaseModel):
    id: str
    transaction_type: str
    amount: float
    payment_method: str
    gateway_trx_id: str
    payment_reference: Optional[str]
    status: str
    notes: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
