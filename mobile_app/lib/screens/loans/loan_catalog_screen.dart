import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/loan_model.dart';
import '../../services/api_service.dart';
import 'loan_calculator_screen.dart';
import 'apply_loan_screen.dart';

class LoanCatalogScreen extends StatefulWidget {
  const LoanCatalogScreen({super.key});

  @override
  State<LoanCatalogScreen> createState() => _LoanCatalogScreenState();
}

class _LoanCatalogScreenState extends State<LoanCatalogScreen> {
  List<LoanProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final products = await ApiService.getLoanProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ক্ষুদ্রঋণ প্যাকেজসমূহ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final prod = _products[index];
                  return _buildProductCard(prod);
                },
              ),
            ),
    );
  }

  Widget _buildProductCard(LoanProductModel prod) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    prod.nameBn,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text(
                    'সুদ: ${prod.interestRate}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prod.description ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailCol('ঋণের পরিমাণ', '৳${prod.minAmount.toInt()} - ৳${prod.maxAmount.toInt()}'),
                  Container(height: 24, width: 1, color: AppColors.border),
                  _buildDetailCol('সর্বোচ্চ মেয়াদ', '${prod.defaultTenureWeeks} সপ্তাহ'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoanCalculatorScreen(
                            initialAmount: prod.minAmount,
                            initialWeeks: prod.defaultTenureWeeks,
                            initialRate: prod.interestRate,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('হিসাব করুন'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplyLoanScreen(
                            selectedProduct: prod,
                            prefilledAmount: prod.minAmount,
                            prefilledWeeks: prod.defaultTenureWeeks,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('আবেদন করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCol(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
