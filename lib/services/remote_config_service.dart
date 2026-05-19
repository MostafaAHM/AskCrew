import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static Future<bool> isAppEnabled() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ),
    );

    await remoteConfig.fetchAndActivate();

    return remoteConfig.getBool('app_enabled');
  }
}
