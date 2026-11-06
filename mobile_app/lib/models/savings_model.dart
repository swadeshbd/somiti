class SavingsAccountModel {
  final String id;
  final String accountNumber;
  final String accountType; // REGULAR, DPS
  final double balance;
  final double monthlyInstallment;
  final double interestRate;
  final String status;

  SavingsAccountModel({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.monthlyInstallment,
    required this.interestRate,
    required this.status,
  });

  factory SavingsAccountModel.fromJson(Map<String, dynamic> json) {
    return SavingsAccountModel(
      id: json['id'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountType: json['account_type'] ?? 'REGULAR',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment: (json['monthly_installment'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
    );
  }
}
