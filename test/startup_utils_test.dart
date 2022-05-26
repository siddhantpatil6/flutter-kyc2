
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/utils/startup_utils.dart';
import 'package:kyc2/utils/from_data.dart';

void main(){

  group('Start_up', (){

    test('type test for the DefaultHeaders ', (){
      expect(StartupUtils.DefaultHeaders, isA<Map<String, String>>());
      expect(StartupUtils.DefaultHeaders['X-cleverTapId'], isA<String>());
      expect(StartupUtils.DefaultHeaders['X-appId'], isA<String>());
    });

    test('key validate ( Valid and Invalid key) for DefaultHeaders ', (){
      expect(StartupUtils.DefaultHeaders.containsKey('X-appsFlyerId'), true );
      expect(StartupUtils.DefaultHeaders.containsKey('Id'), false );
      expect(StartupUtils.DefaultHeaders.containsKey('X-appId'), true );
    });

    test('value validate for DefaultHeaders ', (){
      expect(StartupUtils.DefaultHeaders['Accept-Language'], 'en-US' );
      expect(StartupUtils.DefaultHeaders['Id'], null );
      expect(StartupUtils.DefaultHeaders['X-appId'], '' );
    });

  });

  group('getHeader with JWT token', (){

    var form = FormData();

    test('fetch getHeader with JWT test', (){
      var headerWithJWT = StartupUtils.getHeader(mFormData: form);
      expect(headerWithJWT, isA<Map<String, String>>());

    });

    test('JWT validation from header map', (){
      var headerWithJWT = StartupUtils.getHeader(mFormData: form);
      var token = headerWithJWT['token'];
      expect(token == '1235456', false);

      form.setValue(key: 'token', value: '1235456');
      headerWithJWT = StartupUtils.getHeader(mFormData: form);
      token = headerWithJWT['Authorization'];
      expect(token, 'Bearer 1235456');
    });

  });


}