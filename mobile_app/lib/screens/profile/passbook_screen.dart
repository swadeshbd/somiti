import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../services/api_service.dart';

class PassbookScreen extends StatelessWidget {
  const PassbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    // Demo ledger items
    final transactions = [
      {
        'date': '০৫ নভেম্বর, ২০২৬',
        'type': 'কিস্তি পরিশোধ (Installment #2)',
        'method': 'বিকাশ (bKash)',
        'amount': '৳৭২৪.০০',
        'trxId': 'BK261105A1',
        'status': 'সফল'
      },
      {
        'date': '২৯ অক্টোবর, ২০২৬',
        'type': 'কিস্তি পরিশোধ (Installment #1)',
        'method': 'নগদ (Nagad)',
        'amount': '৳৭২৪.০০',
        'trxId': 'NG261029B8',
        'status': 'সফল'
      },
      {
        'date': '২২ অক্টোবর, ২০২৬',
        'type': 'সঞ্চয় বাধ্যতামূলক জমা',
        'method': 'ক্যাশ / ফিল্ড অফিসার',
        'amount': '৳৫০০.০০',
        'trxId': 'DEP261022C4',
        'status': 'সফল'
      },
      {
        'date': '১৫ অক্টোবর, ২০২৬',
        'type': 'ক্ষুদ্র ব্যবসা ঋণ বিতরণ (Disbursement)',
        'method': 'ব্যাংক ট্রান্সফার',
        'amount': '৳৩০,০০০.০০',
        'trxId': 'DISB20261015',
        'status': 'বিতরণকৃত'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ডিজিটাল পাসবই (লেজার স্টেটমেন্ট)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'প্রিন্ট / PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('অফিসিয়াল ডিজিটাল পাসবই PDF ডাউনলোড সম্পন্ন হয়েছে!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Member info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user?.fullName ?? 'মোহাম্মদ আব্দুর রহিম',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: const Text('ভেরিফাইড সদস্য', style: TextStyle(color: AppColors.success, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('মোবাইল: ${user?.phone ?? "01711223344"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('NID: ${user?.nidNumber ?? "19922692015000123"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financial Summary
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('মোট সঞ্চয়', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('৳৪,৫০০', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('বর্তমান ঋণ বকেয়া', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('৳৩১,৮৬৭', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8A5300))),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'সকল লেনদেনের তালিকা',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            // Transactions list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = transactions[index];
                final isDisbursement = t['type']!.contains('বিতরণ');
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isDisbursement ? Colors.purple.shade50 : Colors.green.shade50,
                          child: Icon(
                            isDisbursement ? Icons.arrow_downward_rounded : Icons.check_circle_outline,
                            size: 18,
                            color: isDisbursement ? Colors.purple : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['type']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('তারিখ: ${t['date']} | ${t['method']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('TrxID: ${t['trxId']}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          t['amount']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDisbursement ? Colors.purple : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
