/// Result model for Google Sign-In authentication
class GoogleAuthResult {
  /// Server auth code (preferred for backend authentication)
  final String? serverAuthCode;

  /// ID token (fallback option if serverAuthCode is not available)
  final String? idToken;

  /// User's email address
  final String? email;

  /// User's display name
  final String? displayName;

  /// User's profile photo URL
  final String? photoUrl;

  GoogleAuthResult({
    this.serverAuthCode,
    this.idToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Check if we have a valid auth code for backend
  bool get hasValidAuthCode =>
      serverAuthCode != null && serverAuthCode!.isNotEmpty;

  @override
  String toString() {
    return 'GoogleAuthResult(serverAuthCode: ${serverAuthCode != null ? "***" : "null"}, '
        'idToken: ${idToken != null ? "***" : "null"}, '
        'email: $email, displayName: $displayName)';
  }
}
