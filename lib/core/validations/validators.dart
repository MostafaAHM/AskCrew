import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/helpers.dart';

import '../app_config/app_strings.dart';
import '../models/country_model.dart';

class CustomValidators {
  static String? validateEmpty(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? AppStrings.requiredField.tr();
    }
    return null;
  }

  static String? validateYear(String? year) {
    if (year == null || year.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (int.tryParse(year) == null) {
      return AppStrings.notAValidValue.tr();
    } else if (int.parse(year) < 1900 ||
        int.parse(year) > DateTime.now().year) {
      return AppStrings.notAValidValue.tr();
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (password.length < 9) {
      return AppStrings.passwordLengthValidation.tr();
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (confirmPassword == password) {
      return null;
    } else {
      return AppStrings.passwordMatchValidation.tr();
    }
  }

  static String? validateEmail(String? value, {String? message}) {
    if (value?.trim().isEmpty ?? true) {
      return message ?? AppStrings.requiredField.tr();
    } else if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.["
      r"a-zA-Z]+",
    ).hasMatch(value!)) {
      return message ?? AppStrings.emailNotValid.tr();
    }
    return null;
  }

  static String? validateEmailORNull(String? value, {String? message}) {
    if (value?.trim().isNotEmpty ?? false) {
      if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\."
        r"[a-zA-Z]+",
      ).hasMatch(value!)) {
        return message ?? 'Email is not valid!';
      }
    }
    return null;
  }

  static String? validatePositiveInteger(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr();
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return AppStrings.notAValidValue.tr();
    }
    return null; // Valid input
  }

  static String? validatePositiveDouble(
    String? value, {
    double? max,
    double? min,
  }) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr();
    }
    double? val = double.tryParse(value);
    if (val == null || (val > (max ?? 999)) || (val < (min ?? 0))) {
      return AppStrings.notAValidValue.tr();
    }

    return null; // Valid input
  }

  static String? validatePhone(String? phone, {CountryModel? country}) {
    if (phone == null || phone.isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (isNumeric(phone) == false) {
      return AppStrings.notAValidValue.tr();
    } else if (country != null && phone.startsWith(country.code.substring(1))) {
      return AppStrings.notAValidValue.tr();
    } else {
      return null;
    }
  }

  static String? validateDropDown(dynamic value, {String? message}) {
    if (value == null) {
      return message ?? AppStrings.requiredField.tr();
    }
    return null;
  }
}
