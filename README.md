# 📱 Microcredit Borrower Mobile App & Backend System
### ক্ষুদ্রঋণ গ্রাহক মোবাইল অ্যাপ্লিকেশন ও ফিন্যান্সিয়াল ব্যাকএন্ড সার্ভিস

একটি সম্পূর্ণ ও আধুনিক **Microcredit (ক্ষুদ্রঋণ) সল্যুশন**, যা বাংলাদেশ মাইক্রোক্রেডিট রেগুলেটরি অথরিটি (MRA) নিয়মাবলী ও গ্রামীণ ব্যাংকিং/এনজিও বাস্তবতার আলোকে তৈরি করা হয়েছে।

---

## 🏛️ আর্কিটেকচার ওভারভিউ (Architecture Overview)

```
New folder/
├── backend/                       # ⚡ FastAPI + PostgreSQL / SQLite REST API
│   ├── app/
│   │   ├── core/                  # Security (JWT), Config, DB connection
│   │   ├── models/                # User, Loan, Installment, Savings, Transaction
│   │   ├── schemas/               # Pydantic v2 Request/Response validation
│   │   ├── services/
│   │   │   └── calculator.py      # Flat Rate & Declining Balance Engine
│   │   ├── routers/
│   │   │   ├── auth.py            # Phone OTP login, e-KYC
│   │   │   ├── loans.py           # Loan catalog, apply, approve & schedule
│   │   │   ├── payments.py        # bKash / Nagad installment payment
│   │   │   └── savings.py         # Regular Savings & DPS
│   │   ├── seed.py                # Auto demo seeder (products, demo user, loans)
│   │   └── main.py                # FastAPI entrypoint with CORS
│   ├── run.py                     # Uvicorn launcher
│   ├── requirements.txt
│   └── .env.example
│
└── mobile_app/                    # 📱 Flutter Mobile App (Android & iOS)
    ├── lib/
    │   ├── constants/             # AppColors, StringsBn (Bangla localized)
    │   ├── models/                # User, Loan, Installment, Savings
    │   ├── services/
    │   │   └── api_service.dart   # HTTP client with offline-ready demo fallback
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── auth/              # Phone & OTP Login
    │   │   ├── home/              # Dashboard with Active Loan & Progress
    │   │   ├── loans/             # Loan Catalog & Interactive EMI Calculator
    │   │   ├── installments/      # Weekly Installments Schedule & Filter
    │   │   ├── payments/          # bKash / Nagad Payment Simulator
    │   │   ├── savings/           # Savings balance, Deposit & Withdraw
    │   │   └── profile/           # e-KYC status, Digital Passbook statement
    │   └── main.dart
    └── pubspec.yaml
```

---

## ⚡ ১. ব্যাকএন্ড সেটআপ ও চালু করার নিয়ম (Backend Setup)

### পদ্ধতি ক: লোকাল রান (Python)
```bash
cd backend
python -m venv venv
venv\Scripts\activate       # Windows
pip install -r requirements.txt
python run.py
```

### পদ্ধতি খ: ডকার দিয়ে রান (Docker Compose - PostgreSQL সহ)
```bash
docker-compose up -d --build
```

সার্ভার চালু হলে ভিজিট করুন:
- **Interactive Swagger API Docs:** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Digital Passbook (ডিজিটাল পাসবই):** [http://localhost:8000/api/v1/statements/passbook](http://localhost:8000/api/v1/statements/passbook)

### অটোমেটেড টেস্ট রান:
```bash
cd backend
pytest
```

> 💡 **নোট:** সার্ভার প্রথমবার চালু হওয়ামাত্র স্বয়ংক্রিয়ভাবে ৪টি ক্ষুদ্রঋণ প্যাকেজ (জাগরণ, সুফলন, অপরাজিতা, বুনিয়াদ) এবং একজন টেস্ট ব্যবহারকারীর জন্য ৪৬ সপ্তাহের চলমান ঋণ ও কিস্তির তালিকা ডাটাবেজে তৈরি হয়ে যাবে।

---

## 📱 ২. ফ্লাটার মোবাইল অ্যাপ চালু করার নিয়ম (Flutter App Setup)

### কমান্ডসমূহ:
```bash
# ১. মোবাইল অ্যাপ ফোল্ডারে প্রবেশ করুন
cd mobile_app

# ২. ডিপেন্ডেন্সি ডাউনলোড করুন
flutter pub get

# ৩. অ্যাপ রান করুন
flutter run
```

### টেস্ট লগইন তথ্য (Demo Credentials):
- **মোবাইল নম্বর:** `01711223344` (অথবা যেকোনো ১১ ডিজিটের নম্বর)
- **ওটিপি কোড:** `123456`

---

## 🧮 ৩. ক্ষুদ্রঋণ হিসাব পদ্ধতি (Financial Logic Included)

1. **Flat Rate (সমহারে সুদ):**
   $$\text{Total Interest} = P \times \frac{R}{100} \times \frac{W}{52}$$
   $$\text{Installment} = \frac{P + \text{Total Interest}}{W}$$
2. **Declining Balance (ক্রমহ্রাসমান কিস্তি):**
   MRA স্ট্যান্ডার্ড অ্যামর্টাইজেশন শিডিউল সাপোর্ট।

---

## ✨ ৪. মূল ফিচারসমূহ (Core Features)

- **e-KYC ও ওটিপি লগইন:** জাতীয় পরিচয়পত্র এবং এসএমএস ভেরিফিকেশন ব্যবস্থা।
- **লাইভ লোন ট্র্যাকার:** মোট ঋণ, পরিশোধিত কিস্তি সংখ্যা এবং বকেয়া আসলের প্রগ্রেস বার।
- **কিস্তির ডিজিটাল শিডিউল:** প্রতিটি কিস্তির আসল, সুদ, শেষ তারিখ ও স্ট্যাটাস (পরিশোধিত/বাকি)।
- **মোবাইল ওয়ালেট পেমেন্ট:** বিকাশ এবং নগদ দিয়ে ঘরে বসেই কিস্তি পরিশোধ ও তাৎক্ষণিক ডিজিটাল রসিদ।
- **সঞ্চয় ও ডিপিএস:** বাধ্যতামূলক সাপ্তাহিক সঞ্চয় ব্যালেন্স ও সরাসরি জমা করার সুবিধা।
- **ডিজিটাল পাসবই:** স্টেটমেন্ট ও হিসাবের স্বচ্ছতা।
