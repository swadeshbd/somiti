from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime

from app.core.database import get_db
from app.core.security import create_access_token, get_pin_hash, verify_pin
from app.models.user import User
from app.schemas.user import (
    UserLoginRequest,
    VerifyOTPRequest,
    TokenResponse,
    UserProfileUpdate,
    UserResponse
)
from app.routers.deps import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication & KYC"])


@router.post("/send-otp")
def send_otp(request: UserLoginRequest, db: Session = Depends(get_db)):
    """
    Sends OTP to borrower phone number.
    (For development/testing, OTP '123456' is accepted for any valid phone).
    """
    clean_phone = request.phone.strip()
    user = db.query(User).filter(User.phone == clean_phone).first()

    if not user:
        # Create user record automatically on first OTP request
        user = User(
            phone=clean_phone,
            is_active=True,
            is_kyc_verified=False
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    return {
        "success": True,
        "message": f"OTP successfully sent to {clean_phone}",
        "dev_hint": "Demo OTP is 123456"
    }


@router.post("/verify-otp", response_model=TokenResponse)
def verify_otp(request: VerifyOTPRequest, db: Session = Depends(get_db)):
    """
    Verifies OTP and issues JWT Bearer token.
    """
    user = db.query(User).filter(User.phone == request.phone.strip()).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # In test environment, 123456 is standard test OTP
    if request.otp != "123456":
        raise HTTPException(status_code=400, detail="Invalid OTP code")

    token = create_access_token(subject=user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user_id=user.id,
        phone=user.phone,
        full_name=user.full_name,
        is_kyc_verified=user.is_kyc_verified
    )


@router.get("/me", response_model=UserResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    """
    Returns current authenticated borrower profile.
    """
    return current_user


@router.put("/kyc", response_model=UserResponse)
def update_kyc(
    payload: UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Submit/Update e-KYC (NID, Full Name, Address, Photo).
    """
    if payload.full_name:
        current_user.full_name = payload.full_name
    if payload.nid_number:
        current_user.nid_number = payload.nid_number
    if payload.address:
        current_user.address = payload.address
    if payload.photo_url:
        current_user.photo_url = payload.photo_url

    # Auto verify if both NID and Full name are provided
    if current_user.nid_number and current_user.full_name:
        current_user.is_kyc_verified = True

    current_user.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(current_user)
    return current_user
