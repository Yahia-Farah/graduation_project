enum UserRole { admin, lawyer, judge, unknown }

UserRole parseRole(String? role) {
  switch ((role ?? '').toUpperCase()) {
    case 'ADMIN':
      return UserRole.admin;
    case 'LAWYER':
      return UserRole.lawyer;
    case 'JUDGE':
      return UserRole.judge;
    default:
      return UserRole.unknown;
  }
}