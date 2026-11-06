import uuid
from datetime import datetime, date
from sqlalchemy import Column, String, Integer, Float, Date, DateTime, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
import enum
from app.core.database import Base


class CalculationType(str, enum.Enum):
    FLAT = "FLAT"
    DECLINING = "DECLINING"


class ApplicationStatus(str, enum.Enum):
    SUBMITTED = "SUBMITTED"
    UNDER_REVIEW = "UNDER_REVIEW"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    DISBURSED = "DISBURSED"


class LoanStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"
    DEFAULTED = "DEFAULTED"


class InstallmentStatus(str, enum.Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    OVERDUE = "OVERDUE"
    PARTIAL = "PARTIAL"


class LoanProduct(Base):
    __tablename__ = "loan_products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    name_bn = Column(String(100), nullable=False)
    code = Column(String(20), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    min_amount = Column(Float, nullable=False)
    max_amount = Column(Float, nullable=False)
    interest_rate = Column(Float, nullable=False)  # Yearly percentage e.g. 12.0 or 24.0%
    calculation_type = Column(String(20), default=CalculationType.FLAT.value)
    default_tenure_weeks = Column(Integer, default=46)  # Standard Bangladesh MRA 46/50 weeks
    processing_fee_pct = Column(Float, default=1.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    applications = relationship("LoanApplication", back_populates="product")
    loans = relationship("Loan", back_populates="product")


class LoanApplication(Base):
    __tablename__ = "loan_applications"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("loan_products.id"), nullable=False)
    requested_amount = Column(Float, nullable=False)
    tenure_weeks = Column(Integer, nullable=False)
    purpose = Column(String(255), nullable=True)
    
    # Guarantor info
    guarantor_name = Column(String(100), nullable=True)
    guarantor_phone = Column(String(20), nullable=True)
    guarantor_nid = Column(String(30), nullable=True)
    guarantor_relation = Column(String(50), nullable=True)

    status = Column(String(30), default=ApplicationStatus.SUBMITTED.value)
    rejection_reason = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="loan_applications")
    product = relationship("LoanProduct", back_populates="applications")
    loan = relationship("Loan", back_populates="application", uselist=False)


class Loan(Base):
    __tablename__ = "loans"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    account_number = Column(String(30), unique=True, index=True, nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    application_id = Column(String(36), ForeignKey("loan_applications.id"), nullable=True)
    product_id = Column(Integer, ForeignKey("loan_products.id"), nullable=False)

    principal_amount = Column(Float, nullable=False)
    interest_rate = Column(Float, nullable=False)
    interest_amount = Column(Float, nullable=False)
    total_payable = Column(Float, nullable=False)
    total_paid = Column(Float, default=0.0)
    total_outstanding = Column(Float, nullable=False)
    
    tenure_weeks = Column(Integer, nullable=False)
    total_installments = Column(Integer, nullable=False)
    paid_installments_count = Column(Integer, default=0)
    installment_amount = Column(Float, nullable=False)

    status = Column(String(30), default=LoanStatus.ACTIVE.value)
    disbursement_date = Column(Date, default=date.today)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="loans")
    product = relationship("LoanProduct", back_populates="loans")
    application = relationship("LoanApplication", back_populates="loan")
    installments = relationship("Installment", back_populates="loan", order_by="Installment.installment_number")


class Installment(Base):
    __tablename__ = "installments"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    loan_id = Column(String(36), ForeignKey("loans.id"), nullable=False)
    installment_number = Column(Integer, nullable=False)
    amount = Column(Float, nullable=False)
    principal_component = Column(Float, nullable=False)
    interest_component = Column(Float, nullable=False)
    due_date = Column(Date, nullable=False)
    
    status = Column(String(20), default=InstallmentStatus.PENDING.value)
    paid_amount = Column(Float, default=0.0)
    paid_date = Column(DateTime, nullable=True)
    transaction_id = Column(String(100), nullable=True)

    loan = relationship("Loan", back_populates="installments")
