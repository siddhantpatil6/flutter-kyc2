import 'package:flutter/cupertino.dart';
import 'package:kyc2/models/get_flows.dart';

class FormData extends ChangeNotifier {
  static Map<String, dynamic> formData = {'defaultEnabled': true};
  static late GetFlows flows;

  void setValue({required String key, required dynamic value}) {
    formData[key] = value ?? '';
    notifyListeners();
  }

  void clearFlagValue(String keySubString){
    var isChangeHappen = false;
    formData.forEach((key, value) {
      if (key.contains(keySubString) && value == 'true') {
        formData[key] = 'false';
        isChangeHappen = true;
      }
    });
    if(isChangeHappen){
      notifyListeners();;
    }
  }

  void clearFlagValueWithoutNotify(String keySubString){
    formData.forEach((key, value) {
      if (key.contains(keySubString) && value == 'true') {
        formData[key] = 'false';
      }
    });
  }

  void setValueWithoutNotifi({required String key, required dynamic value}) {
    formData[key] = value ?? '';
  }

  dynamic getValue({required String key}) {
    return formData[key];
  }

  Map<String, dynamic> getFormData() {
    return formData;
  }

  void setFlows({required GetFlows? flowData}) {
    if (flowData != null) {
      flows = flowData;
      notifyListeners();
    }
  }

  GetFlows getFlows() {
    return flows;
  }
}

// final _FormData FormData = new _FormData();