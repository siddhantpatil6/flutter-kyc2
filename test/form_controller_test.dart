

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/utils/form_controller.dart';

void main(){

  test('getTextEditingController always return TextEditingController', (){
    var controller = PersistedFormController.getTextEditingController('test1');
    expect(controller, isA<TextEditingController>());

  });

  test('getFocusNode always return FocusNode', (){
    var node = PersistedFormController.getFocusNode('test1');
    expect(node, isA<FocusNode>());

  });

  group('GlobalKey<FormState> test', (){

    test('initial should be empty in navKeyTree and navIndexTree', (){
      expect(PersistedFormController.navIndexTree.length, 0);
      expect(PersistedFormController.navKeyTree.length, 0);
    });
    test('getFormKeys always return globalKey', (){
      var globalKey = PersistedFormController.getFormKeys(0);
      expect(globalKey, isA<GlobalKey>());
    });
    test('navKeyTree and navIndexTree size should be increased', (){
      expect(PersistedFormController.navIndexTree.length, 1);
      expect(PersistedFormController.navKeyTree.length, 1);
    });

    test('Add one more key into globalKey', (){
      var globalKey = PersistedFormController.getFormKeys(1);
      expect(globalKey, isA<GlobalKey>());
    });
    test('navKeyTree and navIndexTree size should be increased', (){
      expect(PersistedFormController.navIndexTree.length, 2);
      expect(PersistedFormController.navKeyTree.length, 2);
    });

    test('Add one more key into globalKey and fetch perticular index', (){
      var globalKey = PersistedFormController.getFormKeys(2);
      expect(globalKey, isA<GlobalKey>());
    });


  });

  test('backCurrentNavKeyScreen type test', (){
    expect(PersistedFormController.backCurrentNavKeyScreen, isA<List<String>>());
  });
  test('backNavKeyScreen type test', (){
    expect(PersistedFormController.backNavKeyScreen, isA<List<String>>());
  });
  test('doLaterNavKeyScreen type test', (){
    expect(PersistedFormController.doLaterNavKeyScreen, isA<List<String>>());
  });
  test('backCurrentNavKeyScreen type test', (){
    expect(PersistedFormController.editBankNavKeyScreen, isA<List<String>>());
  });

  test('backCurrentNavKeyScreen list size should be greater than 0', (){
    expect(PersistedFormController.backCurrentNavKeyScreen.length > 0, true);
  });
  test('backNavKeyScreen list size should be greater than 0', (){
    expect(PersistedFormController.backNavKeyScreen.length > 0, true);
  });
  test('doLaterNavKeyScreen list size should be greater than 0', (){
    expect(PersistedFormController.doLaterNavKeyScreen.length > 0, true);
  });
  test('backCurrentNavKeyScreen list size should be greater than 0', (){
    expect(PersistedFormController.editBankNavKeyScreen.length > 0, true);
  });





}