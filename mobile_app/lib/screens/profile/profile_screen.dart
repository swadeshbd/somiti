import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'passbook_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? user;

  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('সদস্য প্রোফাইল'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'মোহাম্মদ আব্দুর রহিম',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '01711223344',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'e-KYC ভেরিফাইড সদস্য',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile info card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.badge_outlined, 'NID নম্বর', user?.nidNumber ?? '19922692015000123'),
                    const Divider(),
                    _infoRow(Icons.location_on_outlined, 'ঠিকানা', user?.address ?? 'গ্রাম: ভবানীপুর, শ্রীপুর, গাজীপুর'),
                    const Divider(),
                    _infoRow(Icons.groups_outlined, 'সমিতি / কেন্দ্র', 'ভবানীপুর সমিতি - ০৩'),
                    const Divider(),
                    _infoRow(Icons.support_agent_outlined, 'মাঠ কর্মকর্তা (FO)', 'কামরুল হাসান (01700998877)'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actions card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                    title: const Text('ডিজিটাল পাসবই (স্টেটমেন্ট ডাউনলোড)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PassbookScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                    title: const Text('নিরাপত্তা ও পিন পরিবর্তন'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('নতুন পিন সেট করুন'),
                          content: const TextField(
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: '৪ ডিজিটের নতুন পিন',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('আপনার পিন সফলভাবে আপডেট করা হয়েছে!')),
                                );
                              },
                              child: const Text('সংরক্ষণ করুন'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: const Text('হেল্পলাইন ও সাপোর্ট'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('গ্রাহক সহায়তা ও হেল্পলাইন'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📞 হটলাইন: 16222 (টোল-ফ্রি)'),
                              SizedBox(height: 8),
                              Text('🏢 শাখা অফিস: গাজীপুর শাখা - ০২'),
                              SizedBox(height: 8),
                              Text('মাঠ কর্মকর্তা: কামরুল হাসান (01700998877)'),
                              SizedBox(height: 8),
                              Text('ইমেইল: support@microcredit.org.bd'),
                            ],
                          ),
                          actions: [
                            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                await ApiService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('লগআউট করুন', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
