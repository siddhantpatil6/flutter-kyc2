import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/models/config_model.dart';
import 'package:kyc2/utils/config_utils.dart';

void main() {
  group('Native config Data test', () {
    var dataFromNative = {
      'channel_name': 'kyc',
      'mobileNumber': '8129098045',
      'key2': '',
      'appsFlyerId': 'appsFlyerId12345',
      'cleverTapId': 'cleverTapId12345',
      'macAddress': '22:22:22:22:22:22',
      'ipAddress': '127.0.0.1',
      'appId': '12345',
      'platform': 'android',
      'appVersion': '001',
      'device': 'android',
      'jwtToken': '123456'
    };
    var configData = ConfigSingleTon.instance.configData =
        ConfigModel.fromJson(dataFromNative);
    test('confid data validation', () {
      //expect(configData.jwtToken , '123456');
      expect(configData.device, 'android');
      expect(configData.appId, '12345');
      expect(configData.appVersion, '001');
      expect(configData.appsFlyerId, 'appsFlyerId12345');
    });
  });
}
