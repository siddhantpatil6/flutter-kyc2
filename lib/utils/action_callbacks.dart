import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/navigation_utils.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/widget_repo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'action_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:contact/contact.dart';

class ActionCallbacks {
  static Map<String, dynamic>? bodyparams;

  static get(String method) {
    switch (method) {
      case 'goBack':
        return goBack;
      case 'onLoad':
        return onLoad;
      case 'onUnload':
        return onUnload;
      case 'navigatorPop':
        return navigatorPop;
      case 'navigatorSignClearPop':
        return navigatorSignClearPop;
      case 'doItlater':
        return doItlater;
      case 'switchBackCamera':
        return switchBackCamera;
      case 'clearFormData':
        return clearFormData;
      case 'preFillData':
        return preFillData;
      case 'exitkyc':
        return exitkyc;
      case 'panCaptureImageAgain':
        return panCaptureImageAgain;
      case 'openURL':
        return openURL;
      case 'getYesBankTokenID':
        return getYesBankTokenID;
      case 'startUPIJourney':
        return startUPIJourney;
      case 'invokeYesBankSDK':
        return invokeYesBankSDK;
    }
  }

  static openURL({required BuildContext context}) async{
    AnalyticHelper.forcePushdata();
    NavigationUtils.pop(context: context);
    String panAadhaarURL = bodyparams?.containsKey("url") ?? false ? bodyparams!["url"] ?? "" : "";
    var url = Uri.encodeFull(panAadhaarURL);
    //var url = Uri.encodeFull("https://eportal.incometax.gov.in/iec/foservices/#/pre-login/bl-link-aadhaar");
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
  }

  static runCallback(
      {required String method,
      required BuildContext context,
      Map<String, dynamic>? params}) {
    debugPrint("runCallback called : ${method} ");

    if (params != null) {
      debugPrint('params on -> $params');
      bodyparams = params;
    }

    if (params != null) passedParams = params;
    var fun = get(method);
    if (fun != null) fun(context: context);
  }

  static goBack({required BuildContext context}) {
    debugPrint("goBack calling");
  }

  static onLoad({required BuildContext context}) {
    debugPrint("onLoad calling");
  }

  static clearFormData({required BuildContext context}) {

    if (bodyparams != null) {
      List<String> paramKeyList = bodyparams![CLEAR_TEXT_FIELD_DATA]
          .toString()
          .toLowerCase()
          .split(":");

      paramKeyList.forEach((keyvalue) {
        PersistedFormController.getTextEditingController(keyvalue).text = '';
        Provider.of<FormData>(context, listen: false)
            .setValue(key: keyvalue, value: '');
      });

      if (bodyparams![CLEAR_LIST_DATA] != null) {
        paramKeyList =
            bodyparams![CLEAR_LIST_DATA].toString().toLowerCase().split(":");

        //debugPrint('clear list value $paramKeyList');

        List<Map<String, dynamic>> tempList = [];
        paramKeyList.forEach((keyvalue) {
          Provider.of<FormData>(context, listen: false)
              .setValue(key: keyvalue, value: tempList);
        });
      }
    }
  }

  static Map<dynamic, dynamic>? passedParams;
  static preFillData({required BuildContext context}) {
    debugPrint("preFillData called------->");

    if (passedParams != null) {
      List<String> paramKeyList =
          passedParams![SAVE_DATA_KEY].toString().toLowerCase().split(":");

      List<String> paramValueList =
          passedParams![SAVE_DATA_VALUE].toString().toLowerCase().split(":");

      int i = 0;
      paramKeyList.forEach((keyvalue) {
        Provider.of<FormData>(context, listen: false)
            .setValue(key: keyvalue, value: paramValueList[i]);
        debugPrint(
            "preFillData called------->" + keyvalue + " " + paramValueList[i]);
        i++;
      });
    }
  }

  static switchBackCamera({required BuildContext context}) async {}

  static onUnload({required BuildContext context}) {
    debugPrint("onUnload calling");
  }

  static navigatorPop({required BuildContext context}) {
    debugPrint("continueApp calling");
    NavigationUtils.pop(context: context);
  }

  static navigatorSignClearPop({required BuildContext context}) {
    debugPrint("continueApp calling");
    NavigationUtils.pop(context: context);
    WidgetRepo.signatureKey.currentState!.clear();
  }

  static doItlater({required BuildContext context}) async {
    NavigationUtils.popTimes(context: context, count: 2);
  }

  static panCaptureImageAgain({required BuildContext context}) async {
    if(PersistedFormController.navScreenNameTree.elementAt(PersistedFormController.navScreenNameTree.length-2)=="pan_preview" || PersistedFormController.navScreenNameTree.elementAt(PersistedFormController.navScreenNameTree.length-2)=="panUpload_preview")
    NavigationUtils.popTimes(context: context, count: 2);
    else
      NavigationUtils.pop(context: context);
  }

  static exitkyc({required BuildContext context}) async {
    WidgetActionHandler.callNative("moveToMain",context);
  }

  static startUPIJourney({required BuildContext context}) async {
    if (Platform.isAndroid) {

      WidgetActionHandler.handleAction(
          context: context,
          screenId: "currentScreen",
          action: WidgetAction(
              api: "/upibank/get_bank_list",
              type: "navigateWithAPI",
              method: "UPIPOST",
              bodyParameters: {
                "P1_YPP_REF_NUMBER": "upiReferenceNumber",
                "P2_DEVICE_TOKEN": 'NA',
                "SOURCE": "spark",
                "PACKAGE_ID": "PACKAGE_ID",
                "IP_ADDRESS": "IP_ADDRESS",
                "DEVICE_ID": "DEVICE_ID",
              }),
          id:"next1",
          analyticID: "bs-verifyyournumber",
          analytic_metaData: "");

    } else {
      WidgetActionHandler.upiFailMoveToBank(context: context);
    }
  }


  static invokeYesBankSDK({required BuildContext context}) async {


      var phoneStatus = await Permission.phone.request();
      if(phoneStatus.isDenied || phoneStatus.isPermanentlyDenied){
        WidgetActionHandler.upiSkipCall(context: context);
        return;
      }else{

        var checkSim = await Contact.getSimInfo;
        if (checkSim != '') {
          debugPrint("KYC UPI checkSim----> " + checkSim.toString());
          WidgetRepo.isDualSim = (checkSim == "1");
        }else{
          WidgetActionHandler.upiFailMoveToBank(context: context);
          return;
        }

        var status = await Permission.sms.request();
        if(status.isDenied || status.isPermanentlyDenied ){
          WidgetActionHandler.upiSkipCall(context: context);
          return;
        }
      }

      // if (status.isDenied || status.isPermanentlyDenied || phoneStatus.isDenied || phoneStatus.isPermanentlyDenied) {
      //   WidgetActionHandler.upiFailMoveToBank(context: context);
      //   return;
      // }



      WidgetActionHandler.handleBottomSheetAction(
          context,
          WidgetAction(
            api: "UPI_SIM_BS",
            type: "openBotomSheet",
            layoutId: "UPI_SIM_BS",
          ),
          WidgetRepo.layouts,
          "bs-verifyyournumber",
          "mobile number:mobile,sim:upi_sim,bank:BankValue,button:next");
  }

  static int upi_bs_count = 0 ;
  static getYesBankTokenID({required BuildContext context}) async {
    var result = await Contact.generateYesbankToken(
        Provider.of<FormData>(context, listen: false).getValue(key: 'mobile') ??
            "",
        Provider.of<FormData>(context, listen: false)
                .getValue(key: 'upi_sim') ??
            'sim1');

    debugPrint("KYC UPI TOKEN----> " + result.toString());

    if (result != null) {
      Map<String, dynamic> resultMap = json.decode(result.toString());

      if (resultMap['status_code'] == '00') {
        Provider.of<FormData>(context, listen: false)
            .setValueWithoutNotifi(key: "YesBankDeviceToken", value: resultMap['device_token']);

        Provider.of<FormData>(context, listen: false)
            .setValueWithoutNotifi(key: "upiReferenceNumber", value: resultMap['ypp_reference_number']);

        Provider.of<FormData>(context, listen: false)
            .setValueWithoutNotifi(key: "PACKAGE_ID", value: resultMap['package']);

        WidgetActionHandler.handleAction(
            context: context,
            screenId: "currentScreen",
            action: WidgetAction(
                api: "/upibank/get_bank_account_detail",
                type: "navigateWithAPI",
                method: "UPIPOST",
                postNavigate: "/upi_user_banklist",
                bodyParameters: {
                  "P1_YPP_REF_NUMBER": "upiReferenceNumber",
                  "P2_DEVICE_TOKEN": 'YesBankDeviceToken',
                  "P3_BANK_CODE": 'bankcode',
                  "P4_USER_MOBILE": 'mobile',
                  "SOURCE": "spark",
                  "PACKAGE_ID": "PACKAGE_ID",
                  "IP_ADDRESS": "IP_ADDRESS",
                  "DEVICE_ID": "DEVICE_ID",
                }),
            id:"next",
            analyticID: "bs-verifyyournumber",
            analytic_metaData: "");
      } else {
        if (WidgetActionHandler.isBottomsheetOpen) {
          NavigationUtils.pop(context: context);
        }
        upi_bs_count ++ ;
        if(upi_bs_count > 2){

          WidgetActionHandler.handleBottomSheetAction(
            context,
            WidgetAction(
                api: "UPI_BANKACC_FAIL_BS",
                type: "openBotomSheet",
                layoutId: "UPI_BANKACC_FAIL_BS"),
            WidgetRepo.layouts,
            'bs-somethingisntright',
            '',
          );

        }else {
          WidgetActionHandler.handleBottomSheetAction(
            context,
            WidgetAction(
                api: "UPI_FAIL_MOBILE",
                type: "openBotomSheet",
                layoutId: "UPI_FAIL_MOBILE"),
            WidgetRepo.layouts,
            'bs-couldnotfindacc',
            '',
          );
        }
      }
    } else {
      WidgetActionHandler.upiFailMoveToBank(context: context);
    }
  }

  static checkSettings({required BuildContext context}) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Camera Permission'),
              content: Text(
                  'This app needs camera access to take pictures for upload user profile photo'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () => {NavigationUtils.pop(context: context)},
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () => openAppSettings(),
                ),
              ],
            ));
  }
}
