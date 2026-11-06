import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/loan_model.dart';
import '../../models/installment_model.dart';
import '../../services/api_service.dart';

class PayInstallmentScreen extends StatefulWidget {
  final LoanModel loan;
  final InstallmentModel installment;
  final VoidCallback onPaymentSuccess;

  const PayInstallmentScreen({
    super.key,
    required this.loan,
    required this.installment,
    required this.onPaymentSuccess,
  });

  @override
  State<PayInstallmentScreen> createState() => _PayInstallmentScreenState();
}

class _PayInstallmentScreenState extends State<PayInstallmentScreen> {
  String _selectedMethod = 'BKASH';
  late TextEditingController _phoneController;
  final _pinController = TextEditingController(text: '12345');
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: ApiService.currentUser?.phone ?? '01711223344');
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final res = await ApiService.payInstallment(
      loanId: widget.loan.id,
      installmentId: widget.installment.id,
      amount: widget.installment.amount,
      paymentMethod: _selectedMethod,
      phone: _phoneController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (res['success'] == true) {
      widget.onPaymentSuccess();
      _showSuccessDialog(res['gateway_trx_id'] ?? 'BK782190');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'পেমেন্ট ব্যর্থ হয়েছে')),
      );
    }
  }

  void _showSuccessDialog(String trxId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
            ),
            const SizedBox(height: 16),
            const Text(
              StringsBn.paymentSuccess,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'কিস্তি #${widget.installment.installmentNumber} সফলভাবে জমা হয়েছে',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _receiptRow('পরিশোধিত টাকা', '${StringsBn.currencySymbol}${widget.installment.amount.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _receiptRow('পেমেন্ট মাধ্যম', _selectedMethod),
                  const SizedBox(height: 6),
                  _receiptRow(StringsBn.trxId, trxId),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('রসিদ বন্ধ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কিস্তি পরিশোধ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      'কিস্তি #${widget.installment.installmentNumber}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${StringsBn.currencySymbol}${widget.installment.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    _billDetailRow('আসল (Principal)', '৳${widget.installment.principalComponent.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _billDetailRow('সার্ভিস চার্জ (Interest)', '৳${widget.installment.interestComponent.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _billDetailRow('শেষ তারিখ', widget.installment.dueDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              StringsBn.selectPaymentMethod,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Payment Methods
            Row(
              children: [
                Expanded(
                  child: _buildMethodCard('BKASH', 'বিকাশ', AppColors.bkash),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodCard('NAGAD', 'নগদ', AppColors.nagad),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodCard('ROCKET', 'রকেট', AppColors.rocket),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Wallet details form
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedMethod ওয়ালেট তথ্য',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'ওয়ালেট মোবাইল নম্বর',
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ওয়ালেট পিন নম্বর (PIN)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMethod == 'BKASH'
                    ? AppColors.bkash
                    : (_selectedMethod == 'NAGAD' ? AppColors.nagad : AppColors.rocket),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      '৳${widget.installment.amount.toStringAsFixed(0)} পরিশোধ করুন',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(String key, String title, Color color) {
    final isSelected = _selectedMethod == key;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Text(
                title[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billDetailRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
