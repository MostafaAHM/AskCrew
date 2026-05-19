import 'package:easy_localization/easy_localization.dart';

extension TranslationExtension on String {
  /// Translates the key with a fallback text if translation is missing
  /// If the translation key doesn't exist, returns the fallback text
  String trOrFallback(String fallback) {
    try {
      final translated = this.tr();
      // If translation returns the same key (meaning translation not found), return fallback
      // Check if the translated string is the same as the key (no translation found)
      if (translated == this && contains('_')) {
        return fallback;
      }
      return translated;
    } catch (e) {
      return fallback;
    }
  }

  /// Translates the key, returns the key itself if translation is missing (for debugging)
  String trSafe() {
    try {
      final translated = this.tr();
      // If translation returns the same key (meaning translation not found), return a default message
      if (translated == this && contains('_')) {
        return 'Translation missing: $this';
      }
      return translated;
    } catch (e) {
      return this;
    }
  }
}
