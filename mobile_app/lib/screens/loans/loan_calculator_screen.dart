import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../services/api_service.dart';
import 'apply_loan_screen.dart';

class LoanCalculatorScreen extends StatefulWidget {
  final double initialAmount;
  final int initialWeeks;
  final double initialRate;

  const LoanCalculatorScreen({
    super.key,
    this.initialAmount = 30000.0,
    this.initialWeeks = 46,
    this.initialRate = 12.5,
  });

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  late double _amount;
  late int _weeks;
  late double _rate;

  double _weeklyInstallment = 0.0;
  double _totalInterest = 0.0;
  double _totalPayable = 0.0;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    _weeks = widget.initialWeeks;
    _rate = widget.initialRate;
    _recalculate();
  }

  void _recalculate() {
    _totalInterest = (_amount * (_rate / 100.0) * (_weeks / 52.0)).roundToDouble();
    _totalPayable = _amount + _totalInterest;
    _weeklyInstallment = (_totalPayable / _weeks).roundToDouble();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কিস্তি ও লোন ক্যালকুলেটর'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Display Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'আনুমানিক সাপ্তাহিক কিস্তি',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${StringsBn.currencySymbol}${_weeklyInstallment.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCalcStat('মোট সুদ/সার্ভিস চার্জ', '${StringsBn.currencySymbol}${_totalInterest.toStringAsFixed(0)}'),
                      Container(height: 30, width: 1, color: Colors.white24),
                      _buildCalcStat('মোট পরিশোধযোগ্য', '${StringsBn.currencySymbol}${_totalPayable.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Controls Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Amount Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ঋণের পরিমাণ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${StringsBn.currencySymbol}${_amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _amount,
                      min: 10000,
                      max: 100000,
                      divisions: 18,
                      activeColor: AppColors.primary,
                      label: '${_amount.toInt()} BDT',
                      onChanged: (val) {
                        _amount = val;
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tenure Weeks Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'পরিশোধের মেয়াদ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '$_weeks সপ্তাহ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _weeks.toDouble(),
                      min: 24,
                      max: 52,
                      divisions: 14,
                      activeColor: AppColors.primary,
                      label: '$_weeks সপ্তাহ',
                      onChanged: (val) {
                        _weeks = val.toInt();
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Interest rate note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'সুদের হার: $_rate% (MRA নির্দেশিকা অনুযায়ী ফ্ল্যাট রেট হিসাব)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Proceed Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyLoanScreen(
                      prefilledAmount: _amount,
                      prefilledWeeks: _weeks,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'এই ঋণের জন্য আবেদন করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
