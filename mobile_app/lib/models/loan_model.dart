import 'installment_model.dart';

class LoanProductModel {
  final int id;
  final String name;
  final String nameBn;
  final String code;
  final String? description;
  final double minAmount;
  final double maxAmount;
  final double interestRate;
  final String calculationType;
  final int defaultTenureWeeks;

  LoanProductModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.code,
    this.description,
    required this.minAmount,
    required this.maxAmount,
    required this.interestRate,
    required this.calculationType,
    required this.defaultTenureWeeks,
  });

  factory LoanProductModel.fromJson(Map<String, dynamic> json) {
    return LoanProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameBn: json['name_bn'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0.0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      calculationType: json['calculation_type'] ?? 'FLAT',
      defaultTenureWeeks: json['default_tenure_weeks'] ?? 46,
    );
  }
}

class LoanModel {
  final String id;
  final String accountNumber;
  final String userId;
  final int productId;
  final double principalAmount;
  final double interestRate;
  final double interestAmount;
  final double totalPayable;
  final double totalPaid;
  final double totalOutstanding;
  final int tenureWeeks;
  final int totalInstallments;
  final int paidInstallmentsCount;
  final double installmentAmount;
  final String status;
  final String disbursementDate;
  final LoanProductModel? product;
  final List<InstallmentModel> installments;

  LoanModel({
    required this.id,
    required this.accountNumber,
    required this.userId,
    required this.productId,
    required this.principalAmount,
    required this.interestRate,
    required this.interestAmount,
    required this.totalPayable,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.tenureWeeks,
    required this.totalInstallments,
    required this.paidInstallmentsCount,
    required this.installmentAmount,
    required this.status,
    required this.disbursementDate,
    this.product,
    this.installments = const [],
  });

  InstallmentModel? get nextPendingInstallment {
    for (var inst in installments) {
      if (!inst.isPaid) return inst;
    }
    return null;
  }

  double get progressPercentage {
    if (totalPayable == 0) return 0.0;
    return (totalPaid / totalPayable).clamp(0.0, 1.0);
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    var rawInstallments = json['installments'] as List? ?? [];
    List<InstallmentModel> parsedInstallments =
        rawInstallments.map((i) => InstallmentModel.fromJson(i)).toList();

    return LoanModel(
      id: json['id'] ?? '',
      accountNumber: json['account_number'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? 0,
      principalAmount: (json['principal_amount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      interestAmount: (json['interest_amount'] as num?)?.toDouble() ?? 0.0,
      totalPayable: (json['total_payable'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble() ?? 0.0,
      tenureWeeks: json['tenure_weeks'] ?? 46,
      totalInstallments: json['total_installments'] ?? 46,
      paidInstallmentsCount: json['paid_installments_count'] ?? 0,
      installmentAmount: (json['installment_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
      disbursementDate: json['disbursement_date'] ?? '',
      product: json['product'] != null ? LoanProductModel.fromJson(json['product']) : null,
      installments: parsedInstallments,
    );
  }
}
