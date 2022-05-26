

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/utils/config_utils.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:provider/provider.dart';

class StartupUtils {

  static Map<String, String> screenProgressMap = {};

  static void preFillForm({required BuildContext context, required String key,required dynamic value}){
      Provider.of<FormData>(context, listen: false).setValue(key: key.toString(), value: value.toString());
      TextEditingController textEditingController =  PersistedFormController.getTextEditingController(key);
      textEditingController.text = value.toString();
  }

  static Map<String, String> get DefaultHeaders {
    return {
      'Accept-Language': 'en-US',
      'X-cleverTapId': ConfigSingleTon.instance.configData?.cleverTapId ?? "",
      'X-appsFlyerId': ConfigSingleTon.instance.configData?.appsFlyerId ?? "",
      'X-source': HEADER_SOURCE,
      'Content-Type': ' application/json',
      "X-platform": ConfigSingleTon.instance.configData?.platform ?? "ios",
     // "X-macAddress": ConfigSingleTon.instance.configData?.macAddress ?? "22:22:22:22:22:22",
     // "X-ipAddress": ConfigSingleTon.instance.configData?.ipAddress ?? "127.0.0.1",
     // "X-location": "Chennai",
      "X-appId": ConfigSingleTon.instance.configData?.appId ?? "",
      "X-appVersion": ConfigSingleTon.instance.configData?.appVersion ?? "",
      "X-device": ConfigSingleTon.instance.configData?.device ?? "",
      "X-requestId": "${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(987656789)}",
    };
  }

  static Map<String, String> getHeader({required FormData mFormData}){
    Map<String, String> headers = {};
    var token=mFormData.getValue(key: 'token')??ACCESS_TOKEN;
    headers['Authorization'] = 'Bearer $token';
    headers.addAll(StartupUtils.DefaultHeaders);
    return headers;
  }
}