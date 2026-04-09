class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String role;
  final bool isActive;
  final int assignedCasesCount;
  final String court;
  final bool isApproved;

  // Used only for creation (POST request)
  final String? nationalId;
  final String? password;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.role,
    required this.isActive,
    required this.assignedCasesCount,
    required this.court,
    required this.isApproved,
    this.nationalId,
    this.password,
  });

  String get fullName => "\$firstName \$lastName";

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      role: json['role'] ?? 'UNKNOWN',
      isActive: json['isActive'] ?? false,
      assignedCasesCount: json['assignedCasesCount'] ?? 0,
      court: json['court'] ?? '',
      isApproved: json['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password ?? "Default@123",
      "age": age,
      "nationalId": nationalId ?? "00000000000000",
      "role": role.toUpperCase(),
      "court": court,
    };
  }

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? role,
    bool? isActive,
    int? assignedCasesCount,
    String? court,
    bool? isApproved,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      assignedCasesCount: assignedCasesCount ?? this.assignedCasesCount,
      court: court ?? this.court,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
