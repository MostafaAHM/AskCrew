// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';

// class SocialAuthHelper {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     serverClientId:
//         '93965493322-95o0gd0non2jbbkd2lo0iaq08u4ch8uc.apps.googleusercontent.com',
//   );

//   static Future<String> facebookSignIn() async {
//     await FacebookAuth.instance.logOut();
//     final LoginResult result = await FacebookAuth.instance.login(
//       loginBehavior: Platform.isAndroid
//           ? LoginBehavior.webOnly
//           : LoginBehavior.nativeWithFallback,
//     );

//     if (result.status != LoginStatus.success) {
//       throw CustomException(
//         result.message ?? AppStrings.somethingWentWrong.tr(),
//         code: 401,
//       );
//     }
//     final AccessToken? accessToken = result.accessToken;
//     if (accessToken == null) {
//       throw CustomException(
//         AppStrings.somethingWentWrong.tr(),
//         code: 401,
//       );
//     }
//     return accessToken.tokenString;
//   }

//   static Future<GoogleSignInAuthentication> googleSignIn() async {
//     await _googleSignIn.signOut();
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) {
//       throw CustomException(
//         AppStrings.somethingWentWrong.tr(),
//         code: 401,
//       );
//     }

//     final googleAuth = await googleUser.authentication;
//     if (googleAuth.accessToken == null || googleAuth.idToken == null) {
//       throw CustomException(
//         AppStrings.somethingWentWrong.tr(),
//         code: 401,
//       );
//     }

//     return googleAuth;
//   }
// }
