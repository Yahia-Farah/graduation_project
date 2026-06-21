class ProfileData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String? court;
  final bool isActive;
  final bool? isApproved;
  final int assignedCasesCount;

  ProfileData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    this.court,
    required this.isActive,
    this.isApproved,
    required this.assignedCasesCount,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      court: json['court'],
      isActive: json['isActive'] ?? false,
      isApproved: json['isApproved'],
      assignedCasesCount: json['assignedCasesCount'] ?? 0,
    );
  }
}
