class AuthValidators {
  static String? requiredField(String v, {String msg = 'هذا الحقل مطلوب'}) {
    if (v.trim().isEmpty) return msg;
    return null;
  }

  static String? email(String v) {
    final value = v.trim();
    if (value.isEmpty) return 'البريد الإلكتروني مطلوب';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
    if (!ok) return 'البريد الإلكتروني غير صحيح';
    return null;
  }

  static String? password(String v) {
    if (v.isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 8) return 'كلمة المرور يجب ألا تقل عن 8 أحرف';
    return null;
  }

  static String? confirmPassword(String pass, String confirm) {
    final err = password(confirm);
    if (err != null) return err;
    if (pass != confirm) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  static String? nationalId(String v) {
    if (v.length < 14) return 'الرقم القومي غير صحيح';
    return null;
  }
}
