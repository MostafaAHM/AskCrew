import '../models/country_model.dart';

class PhoneFormatterHelper {
  static String formatPhone(String phone, CountryModel? country) {
    String formattedPhone = '';
    if (phone.startsWith('0') && country?.code == "+20") {
      formattedPhone = '${country?.code.substring(1)}${phone.substring(1)}';
    } else {
      formattedPhone = '${country?.code.substring(1)}$phone';
    }

    return formattedPhone;
  }

  static String checkAddPlus(String phone) {
    String formattedPhone = '';
    if (phone.startsWith('+')) {
      formattedPhone = phone;
    } else {
      formattedPhone = '+$phone';
    }

    return formattedPhone;
  }

  static formatPhoneNumber(String phone, {String defaultCountryCode = '+20'}) {
    final trimmedPhone = phone.trim();
    if (trimmedPhone.startsWith('+') || trimmedPhone.startsWith('00')) {
      return trimmedPhone;
    }

    final normalizedPhone = trimmedPhone.startsWith('0')
        ? trimmedPhone.substring(1)
        : trimmedPhone;
    return '$defaultCountryCode$normalizedPhone';
  }
}
