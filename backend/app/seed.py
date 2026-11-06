from datetime import date, timedelta, datetime
from app.core.database import SessionLocal
from app.models.user import User
from app.models.loan import LoanProduct, Loan, Installment, LoanStatus, InstallmentStatus
from app.models.savings import SavingsAccount
from app.services.calculator import MicrocreditCalculator


def init_seed_data():
    db = SessionLocal()
    try:
        # 1. Seed Loan Products
        existing_products = db.query(LoanProduct).first()
        if not existing_products:
            products = [
                LoanProduct(
                    name="Micro Enterprise Loan",
                    name_bn="ক্ষুদ্র ব্যবসা ঋণ (জাগরণ)",
                    code="MEL-01",
                    description="দোকান, ক্ষুদ্র ব্যবসা ও ব্যবসার চলতি মূলধন সম্প্রসারণের জন্য সহজ কিস্তিতে ঋণ।",
                    min_amount=10000.0,
                    max_amount=100000.0,
                    interest_rate=12.5,
                    calculation_type="FLAT",
                    default_tenure_weeks=46,
                    processing_fee_pct=1.0
                ),
                LoanProduct(
                    name="Agriculture & Livestock Loan",
                    name_bn="কৃষি ও প্রাণিসম্পদ ঋণ (সুফলন)",
                    code="AGR-02",
                    description="ফসল চাষ, ডেইরি ফার্ম, পোল্ট্রি ও মৎস্য চাষীদের জন্য সহায়ক মৌসুমি ক্ষুদ্রঋণ।",
                    min_amount=15000.0,
                    max_amount=150000.0,
                    interest_rate=12.0,
                    calculation_type="FLAT",
                    default_tenure_weeks=46,
                    processing_fee_pct=1.0
                ),
                LoanProduct(
                    name="Women Entrepreneur Loan",
                    name_bn="নারী উদ্যোক্তা ঋণ (অপরাজিতা)",
                    code="WEL-03",
                    description="স্বাবলম্বী নারী উদ্যোক্তাদের জন্য বিশেষ ছাড়যুক্ত সুবিধাজনক ক্ষুদ্রঋণ।",
                    min_amount=20000.0,
                    max_amount=200000.0,
                    interest_rate=10.0,
                    calculation_type="FLAT",
                    default_tenure_weeks=46,
                    processing_fee_pct=0.5
                ),
                LoanProduct(
                    name="Emergency Relief Loan",
                    name_bn="জরুরি দুর্যোগ ঋণ (বুনিয়াদ)",
                    code="ERL-04",
                    description="জরুরি চিকিৎসা, দুর্যোগ পরবর্তী পুনর্বাসন বা তাৎক্ষণিক প্রয়োজনে স্বল্পমেয়াদি ঋণ।",
                    min_amount=5000.0,
                    max_amount=30000.0,
                    interest_rate=8.0,
                    calculation_type="FLAT",
                    default_tenure_weeks=24,
                    processing_fee_pct=0.0
                )
            ]
            db.add_all(products)
            db.commit()

        # 2. Seed Demo Borrower User
        demo_phone = "01711223344"
        demo_user = db.query(User).filter(User.phone == demo_phone).first()
        if not demo_user:
            demo_user = User(
                phone=demo_phone,
                full_name="মোহাম্মদ আব্দুর রহিম",
                nid_number="19922692015000123",
                address="গ্রাম: ভবানীপুর, ডাকঘর: শ্রীপুর, গাজীপুর",
                photo_url="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300",
                is_active=True,
                is_kyc_verified=True
            )
            db.add(demo_user)
            db.commit()
            db.refresh(demo_user)

            # Create Demo Savings Account
            savings = SavingsAccount(
                account_number="SAV-2026-8801",
                user_id=demo_user.id,
                account_type="REGULAR",
                balance=4500.0,
                monthly_installment=500.0,
                interest_rate=6.0,
                status="ACTIVE"
            )
            db.add(savings)

            # Create an Active Demo Loan of 30,000 BDT
            first_product = db.query(LoanProduct).first()
            calc = MicrocreditCalculator.calculate_flat_rate(
                principal=30000.0,
                annual_rate_pct=first_product.interest_rate,
                tenure_weeks=first_product.default_tenure_weeks,
                start_date=date.today() - timedelta(weeks=4)
            )

            demo_loan = Loan(
                account_number="LN-202602-4521",
                user_id=demo_user.id,
                product_id=first_product.id,
                principal_amount=calc["principal"],
                interest_rate=calc["annual_rate_pct"],
                interest_amount=calc["total_interest"],
                total_payable=calc["total_payable"],
                total_paid=0.0,
                total_outstanding=calc["total_payable"],
                tenure_weeks=calc["tenure_weeks"],
                total_installments=len(calc["schedule"]),
                paid_installments_count=0,
                installment_amount=calc["installment_amount"],
                status=LoanStatus.ACTIVE.value,
                disbursement_date=date.today() - timedelta(weeks=4)
            )
            db.add(demo_loan)
            db.flush()

            # Add installments; mark the first 2 as already paid for realistic display
            for idx, item in enumerate(calc["schedule"]):
                is_past_paid = idx < 2
                inst = Installment(
                    loan_id=demo_loan.id,
                    installment_number=item["installment_number"],
                    amount=item["amount"],
                    principal_component=item["principal_component"],
                    interest_component=item["interest_component"],
                    due_date=item["due_date"],
                    status=InstallmentStatus.PAID.value if is_past_paid else InstallmentStatus.PENDING.value,
                    paid_amount=item["amount"] if is_past_paid else 0.0,
                    paid_date=datetime.now() - timedelta(weeks=3 - idx) if is_past_paid else None,
                    transaction_id=f"BK-PAID{idx+1}09" if is_past_paid else None
                )
                db.add(inst)
                if is_past_paid:
                    demo_loan.total_paid += item["amount"]
                    demo_loan.total_outstanding -= item["amount"]
                    demo_loan.paid_installments_count += 1

            db.commit()

    except Exception as e:
        db.rollback()
        print(f"Error seeding data: {e}")
    finally:
        db.close()
