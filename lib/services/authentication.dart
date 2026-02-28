import 'package:local_auth/local_auth.dart';

class ADauthenticationService {
  final _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    if (!await _auth.isDeviceSupported()) return false;

    return _auth.authenticate(
      localizedReason: 'Please Authenticate',
      options: const AuthenticationOptions(stickyAuth: true),
    );
  }
}