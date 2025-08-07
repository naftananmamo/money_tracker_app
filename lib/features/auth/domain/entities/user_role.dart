enum UserRole {
  tedi,
  abiye,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.tedi:
        return 'Tedi';
      case UserRole.abiye:
        return 'Abiye';
    }
  }
  
  String get displayName {
    switch (this) {
      case UserRole.tedi:
        return 'Tedi';
      case UserRole.abiye:
        return 'Challengers';
    }
  }
  
  bool get isParent => this == UserRole.tedi;
  bool get isChild => this == UserRole.abiye;
}
