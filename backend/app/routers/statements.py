from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from datetime import datetime

from app.core.database import get_db
from app.models.user import User
from app.models.loan import Loan, Installment
from app.models.savings import SavingsAccount
from app.models.transaction import Transaction
from app.routers.deps import get_current_user

router = APIRouter(prefix="/statements", tags=["Digital Passbook & Statements"])


@router.get("/passbook", response_class=HTMLResponse)
def get_printable_passbook(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Returns a beautifully styled, printable Digital Passbook (ডিজিটাল পাসবই) in HTML
    ready for mobile print or PDF export.
    """
    loans = db.query(Loan).filter(Loan.user_id == current_user.id).all()
    savings = db.query(SavingsAccount).filter(SavingsAccount.user_id == current_user.id).all()
    transactions = db.query(Transaction).filter(
        Transaction.user_id == current_user.id
    ).order_by(Transaction.created_at.desc()).all()

    total_savings = sum(s.balance for s in savings)
    total_loan_outstanding = sum(l.total_outstanding for l in loans)

    rows = ""
    for trx in transactions:
        badge_color = "#2e7d32" if "DEPOSIT" in trx.transaction_type or "DISBURSE" in trx.transaction_type else "#00695c"
        rows += f"""
        <tr>
            <td>{trx.created_at.strftime('%d-%m-%Y %I:%M %p')}</td>
            <td><strong>{trx.gateway_trx_id}</strong></td>
            <td>{trx.transaction_type}</td>
            <td>{trx.payment_method}</td>
            <td style="color: {badge_color}; font-weight: bold;">৳{trx.amount:,.2f}</td>
            <td><span class="badge">{trx.status}</span></td>
        </tr>
        """

    html = f"""
    <!DOCTYPE html>
    <html lang="bn">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ডিজিটাল পাসবই - {current_user.full_name or current_user.phone}</title>
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; color: #333; }}
            .header {{ text-align: center; border-bottom: 2px solid #00695c; padding-bottom: 12px; margin-bottom: 20px; }}
            .header h1 {{ color: #00695c; margin: 0 0 5px 0; font-size: 24px; }}
            .header p {{ margin: 0; color: #666; font-size: 14px; }}
            .member-card {{ display: flex; justify-content: space-between; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 15px; border-radius: 8px; margin-bottom: 20px; }}
            .summary-cards {{ display: flex; gap: 15px; margin-bottom: 20px; }}
            .card {{ flex: 1; padding: 15px; border-radius: 8px; background: #f8fafc; border: 1px solid #e2e8f0; }}
            .card h3 {{ margin: 0 0 5px 0; font-size: 13px; color: #64748b; }}
            .card p {{ margin: 0; font-size: 20px; font-weight: bold; color: #0f172a; }}
            table {{ width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13px; }}
            th, td {{ border: 1px solid #cbd5e1; padding: 10px; text-align: left; }}
            th {{ background: #00695c; color: white; }}
            tr:nth-child(even) {{ background: #f8fafc; }}
            .badge {{ background: #e0f2fe; color: #0369a1; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }}
            .print-btn {{ background: #00695c; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-size: 14px; margin-bottom: 15px; }}
            @media print {{ .print-btn {{ display: none; }} }}
        </style>
    </head>
    <body>
        <button class="print-btn" onclick="window.print()">🖨️ প্রিন্ট অথবা PDF সংরক্ষণ করুন</button>
        <div class="header">
            <h1>ক্ষুদ্রঋণ সেবা ও ডিজিটাল পাসবই</h1>
            <p>সদস্য আর্থিক লেনদেন বিবরণী ও অডিট স্টেটমেন্ট</p>
        </div>

        <div class="member-card">
            <div>
                <strong>সদস্যের নাম:</strong> {current_user.full_name or 'সম্মানিত সদস্য'}<br>
                <strong>মোবাইল নম্বর:</strong> {current_user.phone}<br>
                <strong>NID:</strong> {current_user.nid_number or 'যাচাইকৃত'}
            </div>
            <div style="text-align: right;">
                <strong>তৈরির তারিখ:</strong> {datetime.now().strftime('%d %B, %Y')}<br>
                <strong>অবস্থা:</strong> e-KYC ভেরিফাইড<br>
                <strong>সমিতি:</strong> ভবানীপুর কেন্দ্র-০১
            </div>
        </div>

        <div class="summary-cards">
            <div class="card">
                <h3>মোট সঞ্চয় ব্যালেন্স</h3>
                <p style="color: #15803d;">৳{total_savings:,.2f}</p>
            </div>
            <div class="card">
                <h3>বর্তমান ঋণ বকেয়া</h3>
                <p style="color: #b91c1c;">৳{total_loan_outstanding:,.2f}</p>
            </div>
            <div class="card">
                <h3>মোট ট্রানজেকশন</h3>
                <p>{len(transactions)} টি</p>
            </div>
        </div>

        <h3>লেনদেনের বিস্তারিত ইতিহাস (Transaction Ledger)</h3>
        <table>
            <thead>
                <tr>
                    <th>তারিখ ও সময়</th>
                    <th>TrxID</th>
                    <th>বিবরণ</th>
                    <th>মাধ্যম</th>
                    <th>পরিমাণ</th>
                    <th>স্ট্যাটাস</th>
                </tr>
            </thead>
            <tbody>
                {rows if rows else '<tr><td colspan="6" style="text-align:center;">কোনো লেনদেন রেকর্ড পাওয়া যায়নি</td></tr>'}
            </tbody>
        </table>
    </body>
    </html>
    """
    return HTMLResponse(content=html)
