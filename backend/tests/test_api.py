import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_get_loan_products():
    response = client.get("/api/v1/loans/products")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    # Check that Bangladesh specific products exist
    product_names = [p["name_bn"] for p in data]
    assert any("ঋণ" in name for name in product_names)


def test_loan_calculator_endpoint():
    payload = {
        "principal": 25000.0,
        "interest_rate": 12.5,
        "tenure_weeks": 46,
        "calculation_type": "FLAT"
    }
    response = client.post("/api/v1/loans/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["principal"] == 25000.0
    assert data["total_payable"] > 25000.0
    assert len(data["schedule"]) == 46


def test_auth_otp_flow():
    # 1. Send OTP
    phone = "01799887766"
    res1 = client.post("/api/v1/auth/send-otp", json={"phone": phone})
    assert res1.status_code == 200
    assert res1.json()["success"] is True

    # 2. Verify OTP with test code 123456
    res2 = client.post("/api/v1/auth/verify-otp", json={"phone": phone, "otp": "123456"})
    assert res2.status_code == 200
    token_data = res2.json()
    assert "access_token" in token_data
    token = token_data["access_token"]

    # 3. Access authenticated /me endpoint
    headers = {"Authorization": f"Bearer {token}"}
    res3 = client.get("/api/v1/auth/me", headers=headers)
    assert res3.status_code == 200
    assert res3.json()["phone"] == phone
