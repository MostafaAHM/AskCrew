import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/helpers/user_helper.dart';
import '../../data/model/signup_request_model.dart';
import '../../data/model/google_signup_request_model.dart';
import '../../data/repo/register_repository.dart';
import '../../data/services/google_auth_service.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final RegisterRepository repository;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  static SignupCubit get(context) => BlocProvider.of(context);
  SignupCubit(this.repository) : super(SignupInitial());

  Future<void> signup(SignupRequestModel request) async {
    emit(SignupLoading());
    try {
      final result = await repository.registerView(model: request);
      result.fold(
        (failure) => emit(SignupFailure(failure.toString())),
        (response) => emit(SignupSuccess()),
      );
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }

  Future<void> signupWithGoogle({required String phone}) async {
    emit(SignupLoading());
    try {
      // Step 1: Trigger Google Sign-In
      print('🔐 [SIGNUP] Starting Google Sign-In...');
      final googleAuthResult = await _googleAuthService.signIn();

      // Step 2: Validate we have idToken
      if (googleAuthResult.idToken == null ||
          googleAuthResult.idToken!.isEmpty) {
        print('❌ [SIGNUP] No idToken received from Google');
        emit(
          SignupFailure(
            'Google sign-in failed: No authentication token received. '
            'Please try again.',
          ),
        );
        return;
      }

      // Log authentication result (safe - no full token)
      print('✅ [SIGNUP] Google Sign-In successful');
      print('   Email: ${googleAuthResult.email}');
      print(
        '   ID Token: ${googleAuthResult.idToken!.isNotEmpty ? "Present" : "Missing"}',
      );
      print('   Phone: $phone');

      // Step 3: Create request model with idToken
      final requestModel = GoogleSignupRequestModel(
        idToken: googleAuthResult.idToken!,
        phone: phone,
      );

      // Step 4: Call backend API
      print('📡 [SIGNUP] Calling backend...');
      final result = await repository.googleSignupViewer(model: requestModel);

      // Step 5: Handle response
      result.fold(
        (failure) {
          print('❌ [SIGNUP] Backend error: ${failure.message}');
          // Clean up Google session on failure
          _googleAuthService.signOut();
          emit(SignupFailure(failure.message));
        },
        (response) {
          print('✅ [SIGNUP] Backend success - User: ${response.user.fullname}');
          // Update user session helper
          UserHelper.setUser(response.user);

          // Emit success with Google signup flag
          emit(SignupSuccess(isGoogleSignup: true));
        },
      );
    } on Exception catch (e) {
      // Handle specific exceptions (user cancelled, network errors, etc.)
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('⚠️ [SIGNUP] Exception: $errorMessage');
      emit(SignupFailure(errorMessage));
    } catch (e) {
      // Handle unexpected errors
      print('❌ [SIGNUP] Unexpected error: $e');
      emit(SignupFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
