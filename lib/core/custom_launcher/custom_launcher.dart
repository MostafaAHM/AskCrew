import 'package:url_launcher/url_launcher.dart';

import '../../config/routes/app_router.dart';
import '../helpers/messages.dart';
import '../helpers/phone_helper.dart';

class CustomLauncher {
  _showErrorToast(String message) {
    AppMessages.showError(AppRouter.appNavigatorKey.currentContext!, message);
  }

  Future openFacebookPage(String username) async {
    try {
      await _launchSocialMediaAppIfInstalled(
        url: 'https://www.facebook.com/$username', //FaceBook
      );
    } on Exception {
      _showErrorToast("Can't open facebook");
    }
  }

  Future call(String phoneNumber, String clientName) async {
    try {
      // bool res = await FlutterPhoneDirectCaller.callNumber('01149945599')??false;
      final call = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(call)) {
        launchUrl(call);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't call $clientName");
    }
  }

  Future sendMessage(String phoneNumber, String clientName) async {
    try {
      // bool res = await FlutterPhoneDirectCaller.callNumber('01149945599')??false;
      final message = Uri.parse('sms:$phoneNumber');
      if (await canLaunchUrl(message)) {
        launchUrl(message);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't send message to $clientName");
    }
  }

  Future openWhatsApp(String phone) async {
    final formatted = PhoneFormatterHelper.formatPhoneNumber(phone);
    final digits = _toWaDigits(formatted);

    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$digits'),
      Uri.parse('whatsapp://send?phone=+$digits'),
      Uri.parse('https://wa.me/$digits'),
    ];

    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (ok) return;
        }
      } catch (_) {}
    }

    _showErrorToast("Can't open  whatsapp");
  }

  String _toWaDigits(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');

    if (d.startsWith('00')) {
      d = d.substring(2);
    }

    return d;
  }

  Future openLink(String link) async {
    try {
      final message = Uri.parse(link);
      if (await canLaunchUrl(message)) {
        launchUrl(message);
      } else {
        throw link;
      }
    } on Exception {
      _showErrorToast("Can't open $link");
    }
  }

  Future _launchSocialMediaAppIfInstalled({required String url}) async {
    final uri = Uri.parse(url);
    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      ); // Launch the app if installed!

      if (!launched) {
        launchUrl(uri); // Launch web view if app is not installed!
      }
    } catch (e) {
      rethrow; // Launch web view if app is not installed!
    }
  }
}
