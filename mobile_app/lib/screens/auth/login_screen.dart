import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '01711223344');
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 11) {
      setState(() => _errorMessage = 'সঠিক ১১ ডিজিটের মোবাইল নম্বর লিখুন');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ApiService.sendOtp(phone);
    setState(() {
      _isLoading = false;
      if (success) {
        _isOtpSent = true;
        _otpController.text = '123456'; // Pre-filled for demo convenience
      } else {
        _errorMessage = 'ওটিপি পাঠাতে সমস্যা হয়েছে, পুনরায় চেষ্টা করুন';
      }
    });
  }

  Future<void> _handleVerifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() => _errorMessage = '৬ ডিজিটের ওটিপি কোড দিন');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ApiService.verifyOtp(phone, otp);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _errorMessage = 'ভুল ওটিপি কোড! অনুগ্রহ করে আবার চেষ্টা করুন');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                StringsBn.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'আপনার মোবাইল নম্বর দিয়ে লগইন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.pad(BorderSide(color: Colors.red.shade200)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Phone Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isOtpSent,
                decoration: InputDecoration(
                  labelText: 'মোবাইল নম্বর',
                  hintText: StringsBn.phoneHint,
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: _isOtpSent ? Colors.grey.shade100 : Colors.white,
                ),
              ),

              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: '৬ ডিজিট ওটিপি কোড',
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text(
                    StringsBn.demoOtpNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8A5300), fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isOtpSent ? StringsBn.verifyOtp : StringsBn.sendOtp,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              if (_isOtpSent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isOtpSent = false),
                  child: const Text('মোবাইল নম্বর পরিবর্তন করুন'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
