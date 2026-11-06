import pytest
from app.services.calculator import MicrocreditCalculator


def test_flat_rate_calculation():
    # 20,000 BDT loan, 12% annual flat rate, 46 weeks
    principal = 20000.0
    rate = 12.0
    weeks = 46

    result = MicrocreditCalculator.calculate_flat_rate(
        principal=principal,
        annual_rate_pct=rate,
        tenure_weeks=weeks
    )

    assert result["principal"] == 20000.0
    assert result["tenure_weeks"] == 46
    # Interest = 20000 * 0.12 * (46 / 52) = 2123.08
    expected_interest = round(20000.0 * 0.12 * (46 / 52), 2)
    assert result["total_interest"] == expected_interest
    assert result["total_payable"] == round(principal + expected_interest, 2)
    assert len(result["schedule"]) == 46

    # Verify sum of installment amounts equals total payable
    schedule_sum = sum(item["amount"] for item in result["schedule"])
    assert round(schedule_sum, 2) == result["total_payable"]


def test_declining_balance_calculation():
    # 30,000 BDT loan, 24% annual declining rate, 46 weeks
    principal = 30000.0
    rate = 24.0
    weeks = 46

    result = MicrocreditCalculator.calculate_declining_balance(
        principal=principal,
        annual_rate_pct=rate,
        tenure_weeks=weeks
    )

    assert result["principal"] == 30000.0
    assert len(result["schedule"]) == 46
    # The final remaining balance must be 0
    assert result["schedule"][-1]["remaining_balance"] == 0.0
