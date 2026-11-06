import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/loan_model.dart';
import '../../models/installment_model.dart';
import '../payments/pay_installment_screen.dart';

class InstallmentsScreen extends StatefulWidget {
  final LoanModel loan;
  final VoidCallback onPaymentComplete;

  const InstallmentsScreen({
    super.key,
    required this.loan,
    required this.onPaymentComplete,
  });

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Paid

  @override
  Widget build(BuildContext context) {
    List<InstallmentModel> filtered = widget.loan.installments;
    if (_selectedFilter == 1) {
      filtered = filtered.where((i) => !i.isPaid).toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((i) => i.isPaid).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কিস্তির সময়সূচি ও বিবরণ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Loan Summary Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'হিসাব: ${widget.loan.accountNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'মোট কিস্তি: ${widget.loan.totalInstallments} টি | প্রতি কিস্তি: ৳${widget.loan.installmentAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  'বাকি: ৳${widget.loan.totalOutstanding.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          // Filter Segment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip(0, 'সকল কিস্তি (${widget.loan.installments.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(1, 'বাকি (${widget.loan.totalInstallments - widget.loan.paidInstallmentsCount})'),
                const SizedBox(width: 8),
                _buildFilterChip(2, 'পরিশোধিত (${widget.loan.paidInstallmentsCount})'),
              ],
            ),
          ),

          // Installments List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final inst = filtered[index];
                return _buildInstallmentCard(inst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = index),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildInstallmentCard(InstallmentModel inst) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inst.isPaid ? Colors.green.shade200 : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Installment Number Badge
          CircleAvatar(
            radius: 18,
            backgroundColor: inst.isPaid ? Colors.green.shade50 : AppColors.primaryLight,
            child: Text(
              '#${inst.installmentNumber}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: inst.isPaid ? AppColors.success : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${StringsBn.currencySymbol}${inst.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStatusBadge(inst),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'পরিশোধের তারিখ: ${inst.dueDate}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (inst.isPaid && inst.transactionId != null)
                  Text(
                    'TrxID: ${inst.transactionId}',
                    style: const TextStyle(fontSize: 11, color: AppColors.success),
                  ),
              ],
            ),
          ),

          if (!inst.isPaid) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PayInstallmentScreen(
                      loan: widget.loan,
                      installment: inst,
                      onPaymentSuccess: () {
                        widget.onPaymentComplete();
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('পরিশোধ', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InstallmentModel inst) {
    if (inst.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          StringsBn.installmentStatusPaid,
          style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          StringsBn.installmentStatusPending,
          style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}
