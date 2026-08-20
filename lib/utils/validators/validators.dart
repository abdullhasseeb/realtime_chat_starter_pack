class UPFieldValidators {
  UPFieldValidators._();

  /// ---------------- [Common] ----------------

  /// Returns "This field is required" (or custom) when value is empty.
  static String? required(String fieldName, String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    return null;
  }

  /// ----------------[Email] ----------------

  /// Basic + reliable email regex for UI validation (not server-level).
  static final RegExp _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+"
    r"@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
    r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  /// ---------------- [Password] ----------------

  /// Password policy (keep it configurable & readable).
  static String? password(
    String? value, {
    int minLength = 6,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumber = false,
    bool requireSpecial = false,
  }) {
    final v = value ?? '';
    if (v.trim().isEmpty) return 'Password is required';
    if (v.length < minLength) return 'Password must be at least $minLength characters';

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(v)) {
      return 'Password must contain at least 1 lowercase letter';
    }
    if (requireNumber && !RegExp(r'\d').hasMatch(v)) {
      return 'Password must contain at least 1 number';
    }
    if (requireSpecial && !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/$begin:math:display$$end:math:display$]').hasMatch(v)) {
      return 'Password must contain at least 1 special character';
    }

    return null;
  }

  /// ---------------- [Name] ----------------

  static String? fullName(String? value, {int minChars = 2}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Full name is required';
    if (v.length < minChars) return 'Enter at least $minChars characters';
    return null;
  }
}
