import 'app_strings.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyField;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.errorInvalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    if (value.length < 6) {
      return AppStrings.errorWeakPassword;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    if (value != password) {
      return AppStrings.errorPasswordMismatch;
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyField;
    }
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyField;
    }
    final w = double.tryParse(value);
    if (w == null || w <= 0 || w > 500) {
      return AppStrings.errorInvalidWeight;
    }
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyField;
    }
    final h = double.tryParse(value);
    if (h == null || h <= 0 || h > 300) {
      return AppStrings.errorInvalidHeight;
    }
    return null;
  }
}
