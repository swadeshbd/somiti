import math
from typing import List, Dict, Any
from datetime import date, timedelta


class MicrocreditCalculator:
    """
    Financial calculation engine adhering to microcredit standards
    (Supports Flat Rate and Declining Balance / Reducing Balance).
    """

    @staticmethod
    def calculate_flat_rate(
        principal: float,
        annual_rate_pct: float,
        tenure_weeks: int,
        start_date: date = None
    ) -> Dict[str, Any]:
        """
        Standard Flat Rate Calculation:
        Interest = Principal * (Rate / 100) * (Weeks / 52)
        Total Payable = Principal + Interest
        """
        if start_date is None:
            start_date = date.today()

        # Calculate interest based on weekly fraction of the year
        interest = round(principal * (annual_rate_pct / 100.0) * (tenure_weeks / 52.0), 2)
        total_payable = round(principal + interest, 2)
        installment_amount = round(total_payable / tenure_weeks, 2)

        # Generate installment schedule breakdown
        schedule = []
        running_date = start_date
        total_sched_principal = 0.0
        total_sched_interest = 0.0

        principal_per_inst = round(principal / tenure_weeks, 2)
        interest_per_inst = round(interest / tenure_weeks, 2)

        for i in range(1, tenure_weeks + 1):
            running_date += timedelta(days=7)  # Weekly installments

            # Adjust any rounding discrepancy on the last installment
            if i == tenure_weeks:
                p_comp = round(principal - total_sched_principal, 2)
                i_comp = round(interest - total_sched_interest, 2)
                inst_amt = round(p_comp + i_comp, 2)
            else:
                p_comp = principal_per_inst
                i_comp = interest_per_inst
                inst_amt = round(p_comp + i_comp, 2)

            total_sched_principal += p_comp
            total_sched_interest += i_comp

            schedule.append({
                "installment_number": i,
                "due_date": running_date,
                "amount": inst_amt,
                "principal_component": p_comp,
                "interest_component": i_comp
            })

        return {
            "calculation_type": "FLAT",
            "principal": principal,
            "annual_rate_pct": annual_rate_pct,
            "tenure_weeks": tenure_weeks,
            "total_interest": interest,
            "total_payable": total_payable,
            "installment_amount": installment_amount,
            "schedule": schedule
        }

    @staticmethod
    def calculate_declining_balance(
        principal: float,
        annual_rate_pct: float,
        tenure_weeks: int,
        start_date: date = None
    ) -> Dict[str, Any]:
        """
        Reducing/Declining Balance Amortization (MRA Formula):
        PMT = P * [r(1+r)^n] / [(1+r)^n - 1]
        """
        if start_date is None:
            start_date = date.today()

        weekly_rate = (annual_rate_pct / 100.0) / 52.0
        n = tenure_weeks

        if weekly_rate == 0:
            pmt = principal / n
        else:
            pmt = principal * (weekly_rate * math.pow(1 + weekly_rate, n)) / (math.pow(1 + weekly_rate, n) - 1)

        installment_amount = round(pmt, 2)
        balance = principal
        schedule = []
        running_date = start_date
        total_interest = 0.0

        for i in range(1, n + 1):
            running_date += timedelta(days=7)
            interest_comp = round(balance * weekly_rate, 2)
            principal_comp = round(installment_amount - interest_comp, 2)

            # Cap on final installment
            if i == n or principal_comp > balance:
                principal_comp = balance
                installment_amount = round(principal_comp + interest_comp, 2)

            balance = max(0.0, round(balance - principal_comp, 2))
            total_interest += interest_comp

            schedule.append({
                "installment_number": i,
                "due_date": running_date,
                "amount": installment_amount,
                "principal_component": principal_comp,
                "interest_component": interest_comp,
                "remaining_balance": balance
            })

        total_payable = round(principal + total_interest, 2)

        return {
            "calculation_type": "DECLINING",
            "principal": principal,
            "annual_rate_pct": annual_rate_pct,
            "tenure_weeks": tenure_weeks,
            "total_interest": round(total_interest, 2),
            "total_payable": total_payable,
            "installment_amount": round(total_payable / tenure_weeks, 2),
            "schedule": schedule
        }
