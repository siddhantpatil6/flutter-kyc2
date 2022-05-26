
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/from_data.dart';
void main(){

  group('form Data test', (){
    var events = Events(flows: [], data: {});
    var action = FlowAction(type: '', value: ActionValue(name: '', id: ''));
    var form = FormData();
    var getFlow = GetFlows(appNumber: 'SPLM07372376',
        version: '58',
        processDefinitionId: 'kyc-services:19:98ea0ed6-5757-11ec-a96e-0ace7874759e',
        processId: '6d735254-575a-11ec-a96e-0ace7874759e',
        events:events,
        flows: {},
        action: action,
        layouts: {},
        data: {});

    test('initial formData test', (){
      expect(form.getFormData().isNotEmpty, true);

    });

    test('add item test with valid key', (){
      form.setValue(key: 'test1', value: 'first value');
      expect(form.getFormData().containsKey('test1'), true);
    });

    test('get item test with valid key', (){
      var value =  form.getValue(key: 'test1');
      expect(value, 'first value');
    });


    test('get item test with invalid key', (){
      var value =  form.getValue(key: 'test12');
      expect(value, null);
    });

    test('add 4 items and test the length', (){
      form.setValue(key: 'test2', value: 'second value');
      form.setValue(key: 'test3', value: 'third value');
      form.setValue(key: 'test4', value: 'fourth value');
      form.setValue(key: 'test5', value: 'fifth value');
      expect(form.getFormData().length, 6);
    });

    test('add more than 5 items using loop and verifying the data', (){

      for(int i=0;i<10 ; i++){
        form.setValue(key: 'test+${i+6}', value: 'for loop value at index of ${i+6}');
      }
      expect(form.getFormData().length, 16);
    });



    test('add/fetch getFlow test', (){
      form.setFlows(flowData: getFlow);
      var initial = form.getFlows();
      expect(initial, isA<GetFlows>());
    });

    test('verify the values inside the getFlow test', (){
      var initial = form.getFlows();
      expect(initial.appNumber, 'SPLM07372376');
      expect(initial.action.type == 'SPLM07372376', false);
    });



  });




}