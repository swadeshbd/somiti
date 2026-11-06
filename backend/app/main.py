from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import engine, Base
import app.models  # Ensure all SQLAlchemy models are registered
from app.routers import auth, loans, payments, savings, statements
from app.seed import init_seed_data

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Microcredit Borrower Mobile App Backend API (FastAPI + PostgreSQL/SQLite)"
)

# Enable CORS for Flutter app development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(loans.router, prefix=settings.API_V1_STR)
app.include_router(payments.router, prefix=settings.API_V1_STR)
app.include_router(savings.router, prefix=settings.API_V1_STR)
app.include_router(statements.router, prefix=settings.API_V1_STR)


@app.on_event("startup")
def on_startup():
    # Automatically seed microcredit products & demo data
    init_seed_data()


@app.get("/")
def root():
    return {
        "status": "online",
        "service": settings.PROJECT_NAME,
        "docs": "/docs",
        "version": settings.VERSION
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}
