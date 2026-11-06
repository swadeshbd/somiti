class InstallmentModel {
  final String id;
  final String loanId;
  final int installmentNumber;
  final double amount;
  final double principalComponent;
  final double interestComponent;
  final String dueDate;
  final String status; // PENDING, PAID, OVERDUE
  final double paidAmount;
  final String? paidDate;
  final String? transactionId;

  InstallmentModel({
    required this.id,
    required this.loanId,
    required this.installmentNumber,
    required this.amount,
    required this.principalComponent,
    required this.interestComponent,
    required this.dueDate,
    required this.status,
    required this.paidAmount,
    this.paidDate,
    this.transactionId,
  });

  bool get isPaid => status == 'PAID';

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'] ?? '',
      loanId: json['loan_id'] ?? '',
      installmentNumber: json['installment_number'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      principalComponent: (json['principal_component'] as num?)?.toDouble() ?? 0.0,
      interestComponent: (json['interest_component'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'PENDING',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paidDate: json['paid_date'],
      transactionId: json['transaction_id'],
    );
  }
}
