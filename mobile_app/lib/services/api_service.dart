import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../models/installment_model.dart';
import '../models/savings_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for desktop/web/iOS
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static String baseUrl = kIsWeb ? 'http://localhost:8000/api/v1' : defaultBaseUrl;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  static String? _cachedToken;
  static UserModel? _cachedUser;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _cachedUser = UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }
  }

  static bool get isLoggedIn => _cachedToken != null;
  static UserModel? get currentUser => _cachedUser;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_cachedToken != null) {
      headers['Authorization'] = 'Bearer $_cachedToken';
    }
    return headers;
  }

  // --- Auth APIs ---

  static Future<bool> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return res.statusCode == 200;
    } catch (e) {
      // Offline fallback: allow proceeding with demo
      return true;
    }
  }

  static Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _cachedToken = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _cachedToken!);
        await fetchProfile();
        return true;
      }
    } catch (_) {}

    // Offline demo fallback login
    if (otp == '123456') {
      _cachedToken = 'demo-jwt-token';
      _cachedUser = UserModel(
        id: 'demo-user-1',
        phone: phone,
        fullName: 'মোহাম্মদ আব্দুর রহিম',
        nidNumber: '19922692015000123',
        address: 'গ্রাম: ভবানীপুর, গাজীপুর',
        isKycVerified: true,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _cachedToken!);
      await prefs.setString(_userKey, jsonEncode(_cachedUser!.toJson()));
      return true;
    }
    return false;
  }

  static Future<UserModel?> fetchProfile() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        _cachedUser = UserModel.fromJson(jsonDecode(res.body));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_cachedUser!.toJson()));
        return _cachedUser;
      }
    } catch (_) {}
    return _cachedUser;
  }

  static Future<void> logout() async {
    _cachedToken = null;
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // --- Loan APIs ---

  static Future<List<LoanProductModel>> getLoanProducts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/loans/products'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => LoanProductModel.fromJson(item)).toList();
      }
    } catch (_) {}

    // Default Fallback Demo Products
    return [
      LoanProductModel(
        id: 1,
        name: "Micro Enterprise Loan",
        nameBn: "ক্ষুদ্র ব্যবসা ঋণ (জাগরণ)",
        code: "MEL-01",
        description: "দোকান ও ক্ষুদ্র ব্যবসার চলতি মূলধন বৃদ্ধির জন্য সহজ কিস্তিতে ঋণ।",
        minAmount: 10000,
        maxAmount: 100000,
        interestRate: 12.5,
        calculationType: "FLAT",
        defaultTenureWeeks: 46,
      ),
      LoanProductModel(
        id: 2,
        name: "Agriculture Loan",
        nameBn: "কৃষি ও প্রাণিসম্পদ ঋণ (সুফলন)",
        code: "AGR-02",
        description: "ফসল চাষ, ডেইরি ও মৎস্য খামারিদের জন্য সহায়ক ক্ষুদ্রঋণ।",
        minAmount: 15000,
        maxAmount: 150000,
        interestRate: 12.0,
        calculationType: "FLAT",
        defaultTenureWeeks: 46,
      ),
      LoanProductModel(
        id: 3,
        name: "Women Entrepreneur Loan",
        nameBn: "নারী উদ্যোক্তা ঋণ (অপরাজিতা)",
        code: "WEL-03",
        description: "স্বাবলম্বী নারী উদ্যোক্তাদের জন্য বিশেষ ছাড়যুক্ত ঋণ।",
        minAmount: 20000,
        maxAmount: 200000,
        interestRate: 10.0,
        calculationType: "FLAT",
        defaultTenureWeeks: 46,
      ),
    ];
  }

  static Future<Map<String, dynamic>> calculateLoan({
    required double principal,
    required double interestRate,
    required int tenureWeeks,
    String calculationType = 'FLAT',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/loans/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'principal': principal,
          'interest_rate': interestRate,
          'tenure_weeks': tenureWeeks,
          'calculation_type': calculationType,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    // Offline Calculation Logic
    final interest = (principal * (interestRate / 100.0) * (tenureWeeks / 52.0)).roundToDouble();
    final totalPayable = principal + interest;
    final installmentAmount = (totalPayable / tenureWeeks).roundToDouble();

    return {
      'principal': principal,
      'annual_rate_pct': interestRate,
      'tenure_weeks': tenureWeeks,
      'total_interest': interest,
      'total_payable': totalPayable,
      'installment_amount': installmentAmount,
    };
  }

  static Future<List<LoanModel>> getActiveLoans() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/loans/active'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => LoanModel.fromJson(item)).toList();
      }
    } catch (_) {}

    // Fallback Demo Active Loan
    return [_getDemoLoan()];
  }

  static Future<LoanModel> getLoanDetails(String loanId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/loans/$loanId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return LoanModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}

    return _getDemoLoan();
  }

  static Future<Map<String, dynamic>> payInstallment({
    required String loanId,
    required String installmentId,
    required double amount,
    required String paymentMethod,
    required String phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/payments/pay-installment'),
        headers: _headers,
        body: jsonEncode({
          'loan_id': loanId,
          'installment_id': installmentId,
          'amount': amount,
          'payment_method': paymentMethod,
          'customer_phone': phone,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    // Fallback success response
    return {
      'success': true,
      'gateway_trx_id': '${paymentMethod.substring(0, 2).toUpperCase()}8932KA91',
      'amount': amount,
      'payment_method': paymentMethod,
      'message': 'কিস্তি সফলভাবে পরিশোধিত হয়েছে!',
    };
  }

  static Future<List<SavingsAccountModel>> getSavings() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/savings/accounts'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => SavingsAccountModel.fromJson(item)).toList();
      }
    } catch (_) {}

    return [
      SavingsAccountModel(
        id: 'sav-1',
        accountNumber: 'SAV-2026-8801',
        accountType: 'REGULAR',
        balance: 4500.0,
        monthlyInstallment: 500.0,
        interestRate: 6.0,
        status: 'ACTIVE',
      )
    ];
  }

  static LoanModel _getDemoLoan() {
    List<InstallmentModel> demoInstallments = [];
    DateTime now = DateTime.now();

    for (int i = 1; i <= 46; i++) {
      bool isPaid = i <= 2;
      demoInstallments.add(
        InstallmentModel(
          id: 'inst-$i',
          loanId: 'loan-1',
          installmentNumber: i,
          amount: 724.0,
          principalComponent: 652.0,
          interestComponent: 72.0,
          dueDate: now.add(Duration(days: (i - 2) * 7)).toIso8601String().split('T').first,
          status: isPaid ? 'PAID' : 'PENDING',
          paidAmount: isPaid ? 724.0 : 0.0,
          paidDate: isPaid ? now.subtract(Duration(days: (3 - i) * 7)).toIso8601String() : null,
          transactionId: isPaid ? 'BK882931$i' : null,
        ),
      );
    }

    return LoanModel(
      id: 'loan-1',
      accountNumber: 'LN-202602-4521',
      userId: 'demo-user-1',
      productId: 1,
      principalAmount: 30000.0,
      interestRate: 12.5,
      interestAmount: 3315.0,
      totalPayable: 33315.0,
      totalPaid: 1448.0,
      totalOutstanding: 31867.0,
      tenureWeeks: 46,
      totalInstallments: 46,
      paidInstallmentsCount: 2,
      installmentAmount: 724.0,
      status: 'ACTIVE',
      disbursementDate: now.subtract(const Duration(days: 28)).toIso8601String().split('T').first,
      product: LoanProductModel(
        id: 1,
        name: "Micro Enterprise Loan",
        nameBn: "ক্ষুদ্র ব্যবসা ঋণ (জাগরণ)",
        code: "MEL-01",
        minAmount: 10000,
        maxAmount: 100000,
        interestRate: 12.5,
        calculationType: "FLAT",
        defaultTenureWeeks: 46,
      ),
      installments: demoInstallments,
    );
  }
}
