import 'package:local_auth/local_auth.dart';

class ADauthenticationService {
  final LocalAuthentication auth = LocalAuthentication();

  ADauthenticationService();

  Future<bool> authenticate() async {
    bool authenticated = false;

    bool isSupported = await auth.isDeviceSupported();
    if (isSupported) {
      authenticated = await auth.authenticate(
          localizedReason: 'Please Authenticate',
          options: const AuthenticationOptions(
            stickyAuth: true,
          ));
      return authenticated;
    } else {
      return false;
    }
  }
}
