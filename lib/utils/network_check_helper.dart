import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkCheckHelper {
  // static Future<bool> hasNetwork() async {
  //   try {
  //     final result = await InternetAddress.lookup('www.google.com');
  //     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  //   } on SocketException catch (_) {
  //     return false;
  //   }
  // }

  static Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static dynamic checkInternet(Function func) {
    check().then((intenet) {
      if (intenet) {
        func(true);
      } else {
        func(false);
      }
    });
  }
}
