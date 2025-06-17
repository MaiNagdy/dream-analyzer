class User {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final bool emailVerified;
  final int dreamCount;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.emailVerified = false,
    this.dreamCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])
          : null,
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login'])
          : null,
      isActive: json['is_active'] ?? true,
      emailVerified: json['email_verified'] ?? false,
      dreamCount: json['dream_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'email_verified': emailVerified,
      'dream_count': dreamCount,
    };
  }
} 