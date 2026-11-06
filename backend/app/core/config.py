from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "Microcredit Borrower API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Database URL: Supports PostgreSQL (e.g. postgresql://user:pass@localhost:5432/microcredit)
    # Defaults to a local SQLite database for instant local out-of-the-box development and testing.
    DATABASE_URL: str = "sqlite:///./microcredit.db"
    
    SECRET_KEY: str = "super-secret-mra-compliant-key-change-in-production-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
