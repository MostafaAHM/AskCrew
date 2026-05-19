import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/login_request_model.dart';
import '../../data/model/google_login_request_model.dart';
import '../../data/repo/login_repository.dart';
import '../../../viewer/register_viewer/data/services/google_auth_service.dart';
import '../../../../../core/helpers/user_helper.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository loginRepository;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  LoginCubit(this.loginRepository) : super(LoginInitial());

  Future<void> login(LoginRequestModel request) async {
    emit(LoginLoading());
    try {
      final result = await loginRepository.login(model: request);
      result.fold(
        (failure) => emit(LoginFailure(failure.message)),
        (success) => emit(LoginSuccess(success)),
      );
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    try {
      // Step 1: Trigger Google Sign-In
      print('🔐 [LOGIN] Starting Google Sign-In...');
      final googleAuthResult = await _googleAuthService.signIn();

      // Step 2: Validate we have idToken
      if (googleAuthResult.idToken == null ||
          googleAuthResult.idToken!.isEmpty) {
        print('❌ [LOGIN] No idToken received from Google');
        emit(
          LoginFailure(
            'Google sign-in failed: No authentication token received. '
            'Please try again.',
          ),
        );
        return;
      }

      // Log authentication result (safe - no full token)
      print('✅ [LOGIN] Google Sign-In successful');
      print('   Email: ${googleAuthResult.email}');
      print(
        '   ID Token: ${googleAuthResult.idToken!.isNotEmpty ? "Present" : "Missing"}',
      );

      // Step 3: Create request model with idToken
      final requestModel = GoogleLoginRequestModel(
        idToken: googleAuthResult.idToken!,
      );

      // Step 4: Call backend API
      print('📡 [LOGIN] Calling backend...');
      final result = await loginRepository.googleLoginViewer(
        model: requestModel,
      );

      // Step 5: Handle response
      result.fold(
        (failure) {
          print('❌ [LOGIN] Backend error: ${failure.message}');
          // Clean up Google session on failure
          _googleAuthService.signOut();
          emit(LoginFailure(failure.message));
        },
        (response) {
          print('✅ [LOGIN] Backend success - User: ${response.user.fullname}');
          // Update user session helper
          UserHelper.setUser(response.user);

          // Emit success
          emit(LoginSuccess(response));
        },
      );
    } on Exception catch (e) {
      // Handle specific exceptions (user cancelled, network errors, etc.)
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('⚠️ [LOGIN] Exception: $errorMessage');
      emit(LoginFailure(errorMessage));
    } catch (e) {
      // Handle unexpected errors
      print('❌ [LOGIN] Unexpected error: $e');
      emit(LoginFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
