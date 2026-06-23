class PasswordValidator {
  static bool hasMinLength(String s, [int min = 8]) => s.length >= min;
  static bool hasUppercase(String s) => s.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String s) => s.contains(RegExp(r'[a-z]'));
  static bool hasDigit(String s) => s.contains(RegExp(r'\d'));
  static bool hasSpecialChar(String s) => s.contains(RegExp(r'[!@#\$%\^&*(),.?":{}|<>]'));

  static bool isStrong(String s) =>
      hasMinLength(s) && hasUppercase(s) && hasLowercase(s) && hasDigit(s) && hasSpecialChar(s);

  static Map<String, bool> validateAll(String s) => {
        'minLength': hasMinLength(s),
        'uppercase': hasUppercase(s),
        'lowercase': hasLowercase(s),
        'digit': hasDigit(s),
        'special': hasSpecialChar(s),
      };
}
