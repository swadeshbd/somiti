@echo off
echo ====================================================
echo Starting Microcredit FastAPI Backend Server...
echo ====================================================
cd backend
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)
call venv\Scripts\activate
pip install -r requirements.txt
echo.
echo Server starting at http://localhost:8000
echo Swagger documentation at http://localhost:8000/docs
echo ====================================================
python run.py
pause
