from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class UserLoginRequest(BaseModel):
    phone: str = Field(..., example="01712345678")
    pin: Optional[str] = Field(None, example="1234")


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str = Field(..., example="123456")


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    phone: str
    full_name: Optional[str]
    is_kyc_verified: bool


class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    nid_number: Optional[str] = None
    address: Optional[str] = None
    photo_url: Optional[str] = None


class UserResponse(BaseModel):
    id: str
    phone: str
    full_name: Optional[str]
    nid_number: Optional[str]
    address: Optional[str]
    photo_url: Optional[str]
    is_kyc_verified: bool
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True
