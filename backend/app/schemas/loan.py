from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime


class LoanProductResponse(BaseModel):
    id: int
    name: str
    name_bn: str
    code: str
    description: Optional[str]
    min_amount: float
    max_amount: float
    interest_rate: float
    calculation_type: str
    default_tenure_weeks: int
    processing_fee_pct: float

    class Config:
        from_attributes = True


class LoanCalculationRequest(BaseModel):
    principal: float = Field(..., gt=0, example=20000.0)
    interest_rate: float = Field(..., gt=0, example=12.5)
    tenure_weeks: int = Field(..., gt=0, example=46)
    calculation_type: str = Field("FLAT", example="FLAT")


class InstallmentBreakdownItem(BaseModel):
    installment_number: int
    due_date: date
    amount: float
    principal_component: float
    interest_component: float
    remaining_balance: Optional[float] = None


class LoanCalculationResponse(BaseModel):
    calculation_type: str
    principal: float
    annual_rate_pct: float
    tenure_weeks: int
    total_interest: float
    total_payable: float
    installment_amount: float
    schedule: List[InstallmentBreakdownItem]


class LoanApplyRequest(BaseModel):
    product_id: int
    requested_amount: float
    tenure_weeks: int
    purpose: str
    guarantor_name: str
    guarantor_phone: str
    guarantor_nid: str
    guarantor_relation: str


class InstallmentResponse(BaseModel):
    id: str
    loan_id: str
    installment_number: int
    amount: float
    principal_component: float
    interest_component: float
    due_date: date
    status: str
    paid_amount: float
    paid_date: Optional[datetime]
    transaction_id: Optional[str]

    class Config:
        from_attributes = True


class LoanResponse(BaseModel):
    id: str
    account_number: str
    user_id: str
    product_id: int
    principal_amount: float
    interest_rate: float
    interest_amount: float
    total_payable: float
    total_paid: float
    total_outstanding: float
    tenure_weeks: int
    total_installments: int
    paid_installments_count: int
    installment_amount: float
    status: str
    disbursement_date: date
    product: Optional[LoanProductResponse]
    installments: Optional[List[InstallmentResponse]] = []

    class Config:
        from_attributes = True


class LoanApplicationResponse(BaseModel):
    id: str
    user_id: str
    product_id: int
    requested_amount: float
    tenure_weeks: int
    purpose: Optional[str]
    status: str
    rejection_reason: Optional[str]
    created_at: datetime
    product: Optional[LoanProductResponse]

    class Config:
        from_attributes = True
