import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class SavingsAccount(Base):
    __tablename__ = "savings_accounts"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    account_number = Column(String(30), unique=True, index=True, nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    account_type = Column(String(30), default="REGULAR")  # REGULAR, DPS
    balance = Column(Float, default=0.0)
    monthly_installment = Column(Float, default=0.0)
    interest_rate = Column(Float, default=6.0)  # e.g. 6% on savings
    status = Column(String(20), default="ACTIVE")
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="savings_accounts")
    transactions = relationship("Transaction", back_populates="savings_account")
