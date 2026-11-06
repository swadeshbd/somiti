class UserModel {
  final String id;
  final String phone;
  final String? fullName;
  final String? nidNumber;
  final String? address;
  final String? photoUrl;
  final bool isKycVerified;

  UserModel({
    required this.id,
    required this.phone,
    this.fullName,
    this.nidNumber,
    this.address,
    this.photoUrl,
    required this.isKycVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'],
      nidNumber: json['nid_number'],
      address: json['address'],
      photoUrl: json['photo_url'],
      isKycVerified: json['is_kyc_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'nid_number': nidNumber,
      'address': address,
      'photo_url': photoUrl,
      'is_kyc_verified': isKycVerified,
    };
  }
}
