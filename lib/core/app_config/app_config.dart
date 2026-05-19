class AppConfig {
  final String baseUrl;

  AppConfig({required this.baseUrl});

  static AppConfig? _instance;

  static void initialize({required String baseUrl}) {
    _instance = AppConfig(baseUrl: baseUrl);
  }

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception("AppConfig is not initialized");
    }
    return _instance!;
  }

  // Google Sign-In Configuration
  // IMPORTANT: This MUST be the Web OAuth Client ID (not Android client ID)
  // Using the Web Client ID as serverClientId is required to obtain serverAuthCode
  // and avoid ApiException 10 on Android
  static const String googleClientId =
      '364995600400-utd848b0dga59mqn8fud08rdna39itui.apps.googleusercontent.com';

  // Platform-specific redirect URIs for Google Sign-In
  // Android redirect URI - uses the Web client ID in reversed format
  static const String googleRedirectUriAndroid =
      'com.googleusercontent.apps.364995600400-utd848b0dga59mqn8fud08rdna39itui:/oauth2redirect';

  // iOS redirect URI - uses the Web client ID in reversed format
  static const String googleRedirectUriIOS =
      'com.googleusercontent.apps.364995600400-utd848b0dga59mqn8fud08rdna39itui:/oauth2redirect';
}
