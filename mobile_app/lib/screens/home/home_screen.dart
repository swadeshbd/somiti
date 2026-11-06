import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings_bn.dart';
import '../../models/loan_model.dart';
import '../../models/savings_model.dart';
import '../../services/api_service.dart';
import '../installments/installments_screen.dart';
import '../loans/loan_catalog_screen.dart';
import '../loans/loan_calculator_screen.dart';
import '../payments/pay_installment_screen.dart';
import '../savings/savings_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  LoanModel? _activeLoan;
  List<SavingsAccountModel> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final loans = await ApiService.getActiveLoans();
    final savings = await ApiService.getSavings();

    setState(() {
      _isLoading = false;
      if (loans.isNotEmpty) {
        _activeLoan = loans.first;
      }
      _savings = savings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      _activeLoan != null
          ? InstallmentsScreen(loan: _activeLoan!, onPaymentComplete: _loadData)
          : const Center(child: Text("কোনো চলমান ঋণ নেই")),
      const LoanCatalogScreen(),
      SavingsScreen(savingsList: _savings, onRefresh: _loadData),
      ProfileScreen(user: ApiService.currentUser),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'হোম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'কিস্তির তালিকা',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_rounded),
            label: 'ঋণ ক্যাটালগ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_rounded),
            label: 'সঞ্চয়',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final user = ApiService.currentUser;
    final nextInst = _activeLoan?.nextPendingInstallment;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top App Bar / User Greeting
            Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white24,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'সম্মানিত সদস্য',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.verified, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    user?.phone ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overall Financial Quick Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat(
                          title: StringsBn.totalOutstanding,
                          amount: '${StringsBn.currencySymbol}${_activeLoan?.totalOutstanding.toStringAsFixed(0) ?? "0"}',
                          color: Colors.amber,
                        ),
                        Container(height: 36, width: 1, color: Colors.white24),
                        _buildHeaderStat(
                          title: StringsBn.savingsBalance,
                          amount: '${StringsBn.currencySymbol}${_savings.isNotEmpty ? _savings.first.balance.toStringAsFixed(0) : "0"}',
                          color: Colors.lightGreenAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Active Loan Main Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActiveLoanSection(nextInst),
            ),

            const SizedBox(height: 20),

            // Quick Action Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    StringsBn.quickActions,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.calculate_rounded,
                          label: StringsBn.loanCalculator,
                          color: Colors.blue.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoanCalculatorScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.post_add_rounded,
                          label: StringsBn.applyLoan,
                          color: AppColors.primary,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.savings_outlined,
                          label: StringsBn.mySavings,
                          color: Colors.teal.shade700,
                          onTap: () => setState(() => _currentIndex = 3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.format_list_bulleted_rounded,
                          label: 'সকল কিস্তি',
                          color: Colors.deepOrange.shade600,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({required String title, required String amount, required Color color}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveLoanSection(dynamic nextInst) {
    if (_activeLoan == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Text("আপনার কোনো সক্রিয় ঋণ একাউন্ট পাওয়া যায়নি।"),
        ),
      );
    }

    final loan = _activeLoan!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                      loan.product?.nameBn ?? 'ক্ষুদ্র ব্যবসা ঋণ',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'হিসাব নং: ${loan.accountNumber}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Text(
                    'চলমান',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Repayment Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পরিশোধ অগ্রগতি: ${loan.paidInstallmentsCount}/${loan.totalInstallments} কিস্তি',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(loan.progressPercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: loan.progressPercentage,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Upcoming Installment Highlight Box
            if (nextInst != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'পরবর্তী কিস্তি #${nextInst.installmentNumber}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              'পরিশোধের তারিখ: ${nextInst.dueDate}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Text(
                          '${StringsBn.currencySymbol}${nextInst.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PayInstallmentScreen(
                              loan: loan,
                              installment: nextInst,
                              onPaymentSuccess: _loadData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bkash,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.payment_rounded, size: 18),
                      label: const Text(
                        'বিকাশ বা নগদ দিয়ে পরিশোধ করুন',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
