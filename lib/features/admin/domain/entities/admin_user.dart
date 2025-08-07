class AdminUser {
  final String email;
  final String displayName;
  final bool isActive;

  AdminUser({
    required this.email,
    required this.displayName,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'isActive': isActive,
    };
  }
}