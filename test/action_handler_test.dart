import 'package:flutter_shared_widgets/utils/camera_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/models/bank_branch_list_model.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:kyc2/utils/from_data.dart';

void main(){


  test('getCameraUtil always return CameraUtils not null', () {
    var camera = WidgetActionHandler.getCameraUtil();
    expect(camera, isNotNull);
    expect(camera, isA<CameraUtil>());
  });

  test('getActionType() validation', (){

    expect(WidgetActionHandler.getActionType('callAPI'), WidgetActionTypes.callAPI);
    expect(WidgetActionHandler.getActionType('navigateWithAPI'), WidgetActionTypes.navigateWithAPI);
    expect(WidgetActionHandler.getActionType('navigateToRoute'), WidgetActionTypes.navigateToRoute);
    expect(WidgetActionHandler.getActionType('openWebView'), WidgetActionTypes.openWebView);
    expect(WidgetActionHandler.getActionType('openDeepLink'), WidgetActionTypes.openDeepLink);
    expect(WidgetActionHandler.getActionType('not valid one'), WidgetActionTypes.none);

  });

  group('_handleBankandBranchDetails() validation', (){

    // method need to be tested
    List<Map<String, dynamic>> _handleBankandBranchDetails(dynamic obj) {
      BankBranchList list = BankBranchList.fromJson(obj);
      List<Map<String, dynamic>> data = [];

      list.records!.forEach(
            (element) {
          Map<String, dynamic> obj = Map<String, dynamic>();
          if (element.ifsc == null) {
            obj = {'title': element.bank, 'icon': 'bank.png'};
          } else {
            obj = {
              'title': '${element.branch} - ${element.ifsc}',
            };
          }
          data.add(obj);
        },
      );
      return data;
    }

    // sample response
    var validData = {
        "_metadata": {
          "page": 1,
          "pageSize": 5,
          "self": "/v1/bank/list?search=sa\u0026from=0\u0026size=5",
          "previous": "",
          "next": "/v1/bank/list?search=sa\u0026from=5\u0026size=5"
        },
        "records": [
          {"bankCode": "SBLS", "bank": "SAMARTH SAHAKARI BANK LTD"},
          {"bankCode": "TSSB", "bank": "SATARA SAHAKARI BANK LTD"},
          {"bankCode": "SANT", "bank": "SANT SOPANKAKA SAHAKARI BANK LTD"},
          {
            "bankCode": "SNBK",
            "bank": "SARASPUR NAGRIK CO OPERATIVE BANK LTD SARASPUR"
          },
          {"bankCode": "QNBA", "bank": "QATAR NATIONAL BANK SAQ"}
        ]
      };

    var returnResponse = _handleBankandBranchDetails(validData);

    test('response decoding correctly or not', (){
      expect(returnResponse, isA<List<Map<String, dynamic>>>());
      expect(returnResponse[0], isA<Map<String, dynamic>>());
      expect(returnResponse.length > 0, true);
    });
    test('Field Validation in data response array', (){
      expect(returnResponse[0]['title'], 'SAMARTH SAHAKARI BANK LTD');
      expect(returnResponse[0]['icon'], 'bank.png');
      expect(returnResponse[0]['icons'], null);
    });



  });


  group('buildHeaders() test', (){
    
    var action = WidgetAction(api: '/v1/kyc/register', type: 'navigateWithAPI' ,
        headerParameters: {'test_header':'myHeader'});
    var form = FormData();
    form.setValue(key: 'token', value: '1235456');
    form.setValue(key: 'myHeader', value: 'myHeader');

    var header = WidgetActionHandler.buildHeaders(action: action, formData: form);

    test('buildHeaders() will not be return empty or null', (){
      expect(header, isNotNull);
      expect(header.length > 0, true);
    });
    test('buildHeaders() will return a Map', (){
      expect(header, isA<Map<String, String>>());
    });

    test('buildHeaders() should get JWT token and headerParameters ', (){

      expect(header['Authorization'], 'Bearer 1235456');
      expect(header.containsKey('test_header'), true);

    });

  });

  group('buildBody() test', (){
    var action = WidgetAction(api: '/v1/kyc/register', type: 'navigateWithAPI' ,
        headerParameters: {'test_header':'myHeader'},bodyParameters: {'test_body' : 'myBody'});
    var form = FormData();
    form.setValue(key: 'token', value: '1235456');
    form.setValue(key: 'myBody', value: 'Test_body_params');
    form.setValue(key: 'appNumber', value: '12345');
    form.setValue(key: 'flow', value: 'test_flow');
    form.setValue(key: 'id', value: 'test_id');

    var body =  WidgetActionHandler.buildBody(action: action, formData: form);

    test('buildBody() will not be return empty or null', (){
      expect(body, isNotNull);
      expect(body.length > 0, true);
    });

    test('buildBody() will return a Map', (){
      expect(body, isA<Map<String, dynamic>>());
    });

    test('buildHeaders() should get bodyParameters,appNumber,flow,id ', (){

      expect(body.containsKey('data'), true);
      expect(body['data']['test_body'], 'Test_body_params');
      expect(body['appNumber'], '12345');
      expect(body['flow'], 'test_flow');
    });



  });

  group('buildHeadersUpload() test', (){

    var action = WidgetAction(api: '/v1/kyc/register', type: 'navigateWithAPI' );
    var form = FormData();
    var uploadHeader = WidgetActionHandler.buildHeadersUpload(action: action, formData: form);

    test('buildHeadersUpload() will not be return empty or null', (){
      expect(uploadHeader, isNotNull);
      expect(uploadHeader.length > 0, true);
    });

    test('buildHeadersUpload() will return a Map', (){
      expect(uploadHeader, isA<Map<String, String>>());
    });

    test('buildHeadersUpload() should get Content-Type ', (){

      expect(uploadHeader['Content-Type'], 'multipart/form-data');
    });

  });

  group('getRandom() test', (){

    test('getRandom() always returns value', (){
      var random = WidgetActionHandler.getRandom(0);
      expect(random, isNotNull);
      expect(random, isA<String>());
      random = WidgetActionHandler.getRandom(5);
      expect(random, isNotNull);
      expect(random, isA<String>());
    });

    test('getRandom() returns value should match with length we provided', (){
      var random = WidgetActionHandler.getRandom(2);
      expect(random.length, 2);
      random = WidgetActionHandler.getRandom(5);
      expect(random.length, 5);
      random = WidgetActionHandler.getRandom(0);
      expect(random.length, 0);
    });


  });

  group('getImageList() test', (){

    test('getImageList() not returns null ', (){
      var emptylist = WidgetActionHandler.getImageList(imageResID: [], formData: FormData());
      expect(emptylist, isNotNull);
      expect(emptylist, isA<List<String>>());
    });

    var imageResID = ['test1','test2'];
    var formData = FormData();
    formData.setValue(key: 'test1', value: 'test1.jpg');
    formData.setValue(key: 'test2', value: 'test2.jpg');
    var list = WidgetActionHandler.getImageList(imageResID: imageResID, formData: formData);
    test('ImageList should contains key and value ', (){
      expect(list[0], 'test1.jpg');
      expect(list[1], 'test2.jpg');
      print(list);
    });

  });


}