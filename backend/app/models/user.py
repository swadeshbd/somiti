import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    phone = Column(String(20), unique=True, index=True, nullable=False)
    pin_hash = Column(String(255), nullable=True)
    full_name = Column(String(100), nullable=True)
    nid_number = Column(String(30), unique=True, index=True, nullable=True)
    photo_url = Column(String(500), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    is_kyc_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    loan_applications = relationship("LoanApplication", back_populates="user")
    loans = relationship("Loan", back_populates="user")
    savings_accounts = relationship("SavingsAccount", back_populates="user")
    transactions = relationship("Transaction", back_populates="user")
