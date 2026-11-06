import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/savings_model.dart';
import '../../services/api_service.dart';

class SavingsScreen extends StatefulWidget {
  final List<SavingsAccountModel> savingsList;
  final VoidCallback onRefresh;

  const SavingsScreen({
    super.key,
    required this.savingsList,
    required this.onRefresh,
  });

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _depositController = TextEditingController(text: '500');

  void _showDepositDialog(SavingsAccountModel account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('সঞ্চয় জমা করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('একাউন্ট: ${account.accountNumber}'),
            const SizedBox(height: 12),
            TextField(
              controller: _depositController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'জমার পরিমাণ (টাকা)',
                prefixText: '৳ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('বিকাশ/নগদের মাধ্যমে সঞ্চয় সফলভাবে জমা হয়েছে!'),
                  backgroundColor: AppColors.success,
                ),
              );
              widget.onRefresh();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('জমা নিশ্চিত করুন'),
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
        title: const Text('আমার সঞ্চয় ও ডিপিএস'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: widget.savingsList.isEmpty
          ? const Center(child: Text('কোনো সঞ্চয় একাউন্ট নেই'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.savingsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final acc = widget.savingsList[index];
                return _buildSavingsCard(acc);
              },
            ),
    );
  }

  Widget _buildSavingsCard(SavingsAccountModel acc) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acc.accountType == 'DPS' ? 'ডিপিএস একাউন্ট' : 'সাধারণ বাধ্যতামূলক সঞ্চয়',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'হিসাব নং: ${acc.accountNumber}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'সক্রিয়',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'বর্তমান ব্যালেন্স',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                  Text(
                    '${StringsBn.currencySymbol}${acc.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.percent_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'বার্ষিক মুনাফা: ${acc.interestRate}%',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDepositDialog(acc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('টাকা জমা দিন'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('উত্তোলনের আবেদন সংশ্লিষ্ট শাখায় পাঠানো হয়েছে')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                    label: const Text('উত্তোলন রিকোয়েস্ট'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
