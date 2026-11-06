import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    loan_id = Column(String(36), ForeignKey("loans.id"), nullable=True)
    savings_account_id = Column(String(36), ForeignKey("savings_accounts.id"), nullable=True)

    transaction_type = Column(String(50), nullable=False)  # LOAN_INSTALLMENT, LOAN_DISBURSEMENT, SAVINGS_DEPOSIT
    amount = Column(Float, nullable=False)
    payment_method = Column(String(30), nullable=False)  # BKASH, NAGAD, ROCKET, BANK, CASH
    gateway_trx_id = Column(String(100), unique=True, index=True, nullable=False)
    payment_reference = Column(String(100), nullable=True)
    status = Column(String(20), default="COMPLETED")  # PENDING, COMPLETED, FAILED
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="transactions")
    savings_account = relationship("SavingsAccount", back_populates="transactions")
