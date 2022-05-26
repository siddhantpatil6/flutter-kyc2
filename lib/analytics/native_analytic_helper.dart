import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:provider/provider.dart';

import '../utils/config_utils.dart';
import '../utils/from_data.dart';

class NativeAnalyticsHelper {
  static final NativeAnalyticsHelper shared = NativeAnalyticsHelper();

  void logEventWith(List<String>? analyticTypes, String? eventName, String? eventAction, BuildContext context, {String? eventLabel}) {
    if(eventName == null || eventAction == null || analyticTypes == null){
      return;
    }
    var configData = ConfigSingleTon.instance.configData;
    var params = {
      "eventCategory": "KYC2.0",
      "eventAction": eventAction,
      "appName": configData?.appName ?? "",
      "platform": Platform.isAndroid ? "Android" : "iOS",
      "App_ID": configData?.appId ?? "",
      "AUC": "${Provider.of<FormData>(context, listen: false).getValue(
          key: 'appNumber')}",
    };
    if (eventLabel != null) {
      params['eventLabel'] = eventLabel;
    }

    var analyticsData = {
      "analyticTypes" : analyticTypes,
      "eventName":eventName,
      "params":params
    };
    debugPrint("------Firebase log-----------$eventName------------->$analyticsData");
    WidgetActionHandler.sendAnalyticDataToNative(analyticsData, context);
  }

}
