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
  
  // Additional fields for AI-enhanced dream analysis
  final String? ageRange;
  final String? relationshipStatus;
  final String? job;
  final String? hobbies;
  final String? personality;
  final String? currentConcerns;

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
    // Additional AI fields
    this.ageRange,
    this.relationshipStatus,
    this.job,
    this.hobbies,
    this.personality,
    this.currentConcerns,
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
      // Additional AI fields
      ageRange: json['age_range'],
      relationshipStatus: json['relationship_status'],
      job: json['job'],
      hobbies: json['hobbies'],
      personality: json['personality'],
      currentConcerns: json['current_concerns'],
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
      // Additional AI fields
      'age_range': ageRange,
      'relationship_status': relationshipStatus,
      'job': job,
      'hobbies': hobbies,
      'personality': personality,
      'current_concerns': currentConcerns,
    };
  }
  
  // Method to get user context for AI dream analysis
  String getAIContext() {
    List<String> context = [];
    
    if (ageRange != null) context.add('العمر: $ageRange');
    if (gender != null) {
      String genderText = gender == 'male' ? 'ذكر' : 
                         gender == 'female' ? 'أنثى' : 'غير محدد';
      context.add('الجنس: $genderText');
    }
    if (relationshipStatus != null) {
      String statusText = _getRelationshipStatusText(relationshipStatus!);
      context.add('الحالة الاجتماعية: $statusText');
    }
    if (job != null && job!.isNotEmpty) context.add('المهنة: $job');
    if (hobbies != null && hobbies!.isNotEmpty) context.add('الهوايات: $hobbies');
    if (personality != null && personality!.isNotEmpty) context.add('الشخصية: $personality');
    if (currentConcerns != null && currentConcerns!.isNotEmpty) {
      context.add('الاهتمامات الحالية: $currentConcerns');
    }
    
    return context.isEmpty ? '' : 'معلومات عن الشخص: ${context.join(', ')}';
  }
  
  String _getRelationshipStatusText(String status) {
    switch (status) {
      case 'single': return 'أعزب/عزباء';
      case 'married': return 'متزوج/متزوجة';
      case 'divorced': return 'مطلق/مطلقة';
      case 'widowed': return 'أرمل/أرملة';
      default: return 'غير محدد';
    }
  }

  // Added: create a modified copy of the current user instance
  User copyWith({
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? ageRange,
    String? relationshipStatus,
    String? job,
    String? hobbies,
    String? personality,
    String? currentConcerns,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt,
      lastLogin: lastLogin,
      isActive: isActive,
      emailVerified: emailVerified,
      dreamCount: dreamCount,
      ageRange: ageRange ?? this.ageRange,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      job: job ?? this.job,
      hobbies: hobbies ?? this.hobbies,
      personality: personality ?? this.personality,
      currentConcerns: currentConcerns ?? this.currentConcerns,
    );
  }
} 