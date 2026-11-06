import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/loan_model.dart';
import '../../services/api_service.dart';

class ApplyLoanScreen extends StatefulWidget {
  final LoanProductModel? selectedProduct;
  final double prefilledAmount;
  final int prefilledWeeks;

  const ApplyLoanScreen({
    super.key,
    this.selectedProduct,
    this.prefilledAmount = 30000.0,
    this.prefilledWeeks = 46,
  });

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _weeksController;
  final _purposeController = TextEditingController(text: 'দোকানের মালামাল বৃদ্ধি');
  final _guarantorNameController = TextEditingController(text: 'মোঃ আব্দুল করিম');
  final _guarantorPhoneController = TextEditingController(text: '01811223344');
  final _guarantorNidController = TextEditingController(text: '19852692015000456');
  final _guarantorRelationController = TextEditingController(text: 'ভাই');

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.prefilledAmount.toInt().toString());
    _weeksController = TextEditingController(text: widget.prefilledWeeks.toString());
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('আবেদন গৃহীত হয়েছে'),
          ],
        ),
        content: const Text(
          'আপনার ঋণ আবেদনটি সফলভাবে জমা হয়েছে। আমাদের মাঠ কর্মকর্তা শীঘ্রই যাচাইয়ের জন্য আপনার সাথে যোগাযোগ করবেন।',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ঋণের জন্য আবেদন'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product info
              if (widget.selectedProduct != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'নির্বাচিত প্যাকেজ: ${widget.selectedProduct!.nameBn}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),

              // Loan parameters
              _buildSectionHeader('ঋণের তথ্য'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'আবেদনের পরিমাণ (টাকা)',
                  prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'পরিমাণ লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _weeksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'মেয়াদ (সপ্তাহ সংখ্যা)',
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'মেয়াদ লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(
                  labelText: 'ঋণের উদ্দেশ্য',
                  prefixIcon: const Icon(Icons.business_center_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'উদ্দেশ্য লিখুন' : null,
              ),

              const SizedBox(height: 24),

              // Guarantor Information
              _buildSectionHeader('জামিনদারের তথ্য (Guarantor)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _guarantorNameController,
                decoration: InputDecoration(
                  labelText: 'জামিনদারের পুরো নাম',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'নাম লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _guarantorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'জামিনদারের মোবাইল নম্বর',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'মোবাইল নম্বর লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _guarantorNidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'জামিনদারের NID নম্বর',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'NID লিখুন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _guarantorRelationController,
                decoration: InputDecoration(
                  labelText: 'সম্পর্ক (যেমন: ভাই, বাবা, প্রতিবেশী)',
                  prefixIcon: const Icon(Icons.people_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'সম্পর্ক লিখুন' : null,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'আবেদন দাখিল করুন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
    );
  }
}
