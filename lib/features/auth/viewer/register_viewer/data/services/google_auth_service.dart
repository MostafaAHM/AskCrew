import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../../../core/app_config/app_config.dart';
import '../model/google_auth_result.dart';

/// Service class for handling Google Sign-In authentication
///
/// This service manages the Google Sign-In flow and retrieves
/// the necessary authentication data for backend verification.
class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  /// Initialize GoogleSignIn with proper configuration
  ///
  /// IMPORTANT: serverClientId is required to obtain serverAuthCode
  /// which is needed by the backend for authentication
  ///
  /// NOTE: forceCodeForRefreshToken is set to true to request offline access
  /// and ensure serverAuthCode is generated when possible
  void _initializeGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      // Request necessary scopes for user information
      scopes: ['email', 'profile', 'openid'],
      // Server client ID is CRITICAL for getting serverAuthCode
      // This must match the Web OAuth Client ID configured in Google Cloud Console
      serverClientId: AppConfig.googleClientId,
      // Force generation of auth code for refresh token (offline access)
      // This increases the likelihood of receiving serverAuthCode
      forceCodeForRefreshToken: true,
    );
  }

  /// Sign in with Google and return authentication result
  ///
  /// Returns [GoogleAuthResult] containing:
  /// - idToken: JWT token for backend authentication (always available)
  /// - email, displayName, photoUrl: User profile information
  ///
  /// NOTE: We only use idToken for backend authentication.
  /// serverAuthCode is not required for this implementation.
  ///
  /// Throws exception if:
  /// - User cancels the sign-in
  /// - Sign-in fails for any reason
  Future<GoogleAuthResult> signIn() async {
    try {
      dev.log('🔐 Starting Google Sign-In flow...', name: 'GoogleAuth');

      // Sign out first to ensure clean state and account selection
      await _googleSignIn.signOut();

      // Trigger the Google Sign-In flow
      dev.log('📱 Triggering Google Sign-In UI...', name: 'GoogleAuth');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (account == null) {
        dev.log('❌ User cancelled Google Sign-In', name: 'GoogleAuth');
        throw Exception('Google sign-in cancelled by user');
      }

      dev.log('✅ Account selected: ${account.email}', name: 'GoogleAuth');

      // Get authentication details
      dev.log('🔑 Retrieving authentication tokens...', name: 'GoogleAuth');
      final GoogleSignInAuthentication auth = await account.authentication;

      // Log token availability (safe - no full token exposure)
      dev.log(
        '📊 Authentication Tokens:\n'
        '  - idToken: ${auth.idToken != null ? "✓ Available" : "✗ Missing"}\n'
        '  - serverAuthCode: ${auth.serverAuthCode != null ? "Available (not used)" : "null (not needed)"}',
        name: 'GoogleAuth',
      );

      // Validate idToken is available
      if (auth.idToken == null || auth.idToken!.isEmpty) {
        dev.log(
          '❌ idToken is missing - this should not happen',
          name: 'GoogleAuth',
        );
        await _googleSignIn.signOut();
        throw Exception(
          'Google sign-in failed: No ID token received. Please try again.',
        );
      }

      dev.log('✅ Google Sign-In successful with idToken!', name: 'GoogleAuth');

      // Return the authentication result
      return GoogleAuthResult(
        serverAuthCode: auth.serverAuthCode,
        idToken: auth.idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on PlatformException catch (e) {
      // Handle specific Android platform exceptions
      dev.log(
        '❌ PlatformException during Google Sign-In:\n'
        '  Code: ${e.code}\n'
        '  Message: ${e.message}\n'
        '  Details: ${e.details}',
        name: 'GoogleAuth',
        error: e,
      );

      // Ensure we're signed out on error
      await _googleSignIn.signOut();

      // Provide user-friendly error messages based on error code
      switch (e.code) {
        case 'sign_in_failed':
          if (e.message?.contains('10') == true ||
              e.details.toString().contains('10')) {
            dev.log(
              '🛑 ApiException 10 detected! This is ALWAYS a config error.',
              name: 'GoogleAuth',
            );
            throw Exception(
              'Configuration Error (ApiException 10).\n'
              'The Android OAuth Client missing or has wrong SHA-1/Package Name.\n'
              'See APP_GOOGLE_SIGNIN_RUNBOOK.md for the fix.',
            );
          }
          throw Exception(
            'Google Sign-In failed. Please ensure:\n'
            '1. Google Play Services is installed and updated\n'
            '2. Device has internet connection\n'
            '3. App is configured correctly in Google Console',
          );
        case 'network_error':
          throw Exception(
            'Network error. Please check your internet connection and try again.',
          );
        case 'sign_in_canceled':
          throw Exception('Google sign-in cancelled by user');
        case 'sign_in_required':
          throw Exception('Sign-in required. Please try again.');
        default:
          throw Exception('Google Sign-In error: ${e.message ?? e.code}');
      }
    } catch (e) {
      // Handle other exceptions
      dev.log(
        '❌ Unexpected error during Google Sign-In',
        name: 'GoogleAuth',
        error: e,
      );

      // Ensure we're signed out on error
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      dev.log('✅ Signed out from Google', name: 'GoogleAuth');
    } catch (e) {
      dev.log(
        '⚠️ Error during sign-out (ignored)',
        name: 'GoogleAuth',
        error: e,
      );
      // Ignore sign-out errors
    }
  }

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      dev.log('✅ Disconnected from Google', name: 'GoogleAuth');
    } catch (e) {
      dev.log(
        '⚠️ Error during disconnect (ignored)',
        name: 'GoogleAuth',
        error: e,
      );
      // Ignore disconnect errors
    }
  }
}
