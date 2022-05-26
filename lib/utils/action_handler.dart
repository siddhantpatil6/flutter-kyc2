import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:contact/contact.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shared_widgets/widgets/custom_toast.dart';
import 'package:hypersnapsdk_flutter/HVFaceCapture.dart';
import 'package:hypersnapsdk_flutter/HVHyperSnapParams.dart';
import 'package:hypersnapsdk_flutter/HyperSnapSDK.dart';
import 'package:intl/intl.dart';
import 'package:kyc2/analytics/native_analytic_helper.dart';
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/main.dart';
import 'package:kyc2/models/bank_branch_list_model.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/models/http_error.dart';
import 'package:kyc2/models/http_success.dart';
import 'package:kyc2/models/hyperverge_result.dart';
import 'package:kyc2/utils/action_callbacks.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/navigation_utils.dart';
import 'package:kyc2/utils/network_check_helper.dart';
import 'package:kyc2/utils/network_client.dart';
import 'package:kyc2/utils/startup_utils.dart';
import 'package:kyc2/utils/widget_repo.dart';
import 'package:kyc2/widgets/dynamic_layout.dart';
import 'package:path/path.dart';
import 'package:navigator/navigator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_shared_widgets/utils/camera_util.dart';

enum WidgetActionTypes {
  navigateWithAPI,
  navigateToRoute,
  openWebView,
  openDeepLink,
  openBotomSheet,
  openCallback,
  openPanAadhaarSeedBottomsheet,
  callAPI,
  captureImage,
  openHyperSnap,
  captureFromGallery,
  navigateToHost,
  none
}

class WidgetActionHandler {
  static CameraUtil? cameraUtil;
  static bool isBottomsheetOpen = false;
  static bool doUPI = true;
  static int apiFailedUPI = 0;
  static Function(Map<String,String>)? futterToFlutterCallback;
  static NavigatorPlugin? _navigatorPlugin;

  static Future<void> initializeCamera() async {
    try {
      // initialize cameras.
      cameraUtil = new CameraUtil();
      await cameraUtil!.initializeCamera(CameraLensDirection.back, true);
    } on CameraException catch (e) {
      debugPrint(e.toString());
      debugPrint("Camera Util Log : " + "Camera Object not initialised");
    }
  }

  static CameraUtil? getCameraUtil() {
    if (cameraUtil == null) {
      cameraUtil = new CameraUtil();
    }
    return cameraUtil;
  }

  static void initializeNavigator() {
    _navigatorPlugin = NavigatorPlugin();
    _navigatorPlugin?.initChannelWithId('main-app');
  }

  static NavigatorPlugin? getNavigatorPlugin(){
    return _navigatorPlugin;
  }

  static NetworkClient networkClient = new NetworkClient(
    baseUrl: appConfig[BASE_URL_KEY],
    retryMilliseconds: RETRY_MILLISECONDS,
    headers: StartupUtils.DefaultHeaders,
  );

  static getActionType(String actionType) {
    switch (actionType) {
      case 'callAPI':
        return WidgetActionTypes.callAPI;
      case 'navigateWithAPI':
        return WidgetActionTypes.navigateWithAPI;
      case 'navigateToRoute':
        return WidgetActionTypes.navigateToRoute;
      case 'openWebView':
        return WidgetActionTypes.openWebView;
      case 'openDeepLink':
        return WidgetActionTypes.openDeepLink;
      case 'openBotomSheet':
        return WidgetActionTypes.openBotomSheet;
      case 'captureImage':
        return WidgetActionTypes.captureImage;
      case 'captureFromGallery':
        return WidgetActionTypes.captureFromGallery;
      case'openHyperSnap':
        return WidgetActionTypes.openHyperSnap;
      case 'openCallback':
        return WidgetActionTypes.openCallback;
      case 'navigateToHost':
        return WidgetActionTypes.navigateToHost;
      case "openPanAadhaarSeedBottomsheet":
        return WidgetActionTypes.openPanAadhaarSeedBottomsheet;
      default:
        return WidgetActionTypes.none;
    }
  }

 // static void initHyperSnapSDK({required BuildContext context,
 //   required WidgetAction action}) async {
 //   //HyperSnapSDK.startUserSession("pui7nacze6xz");
 //    // TODO: Add appId and appKey
 //    var appID = "2d0d7a";
 //    var appKey = "75b8cbab563da3c508ed";
 //    await HyperSnapSDK.initialize(appID, appKey,
 //        (await HVHyperSnapParams.getValidParams())["RegionIndia"]).then((value) => Future.delayed(const Duration(milliseconds: 500), () {
 //
 //      openFaceCaptureScreen(context: context, action: action);
 //
 //    }));
 //  }
  static void openFaceCaptureScreen({required BuildContext context,
    required WidgetAction action, required FormData formData}) async {
    Map faceCaptureMap = await HVFaceCapture.faceCaptureStart();
    Map faceResultObj = faceCaptureMap["resultObj"];
    Map faceErrorObj = faceCaptureMap["errorObj"];

    // debugPrint("Results Map - " + faceResultObj.toString());
    // debugPrint("Error Map - " + faceErrorObj.toString());

    //consider the capture button is tapped for hyperverge - for analytic part
    AnalyticHelper.logClickEvent(
      analyticID: 's-clickaselfie',
      component: BUTTON,
      id: '',
      flowvalue: 'hypersnap_selfie',
      metaData: {'message body:':'Click a Selfie'}
    );

    if (faceErrorObj.isNotEmpty) {
      // Handle error
      debugPrint(faceErrorObj["errorMessage"]);
      debugPrint(faceErrorObj["errorCode"]?.toString());
      if(formData.getValue(key: action.api) == null){
        NavigationUtils.pop(context: context);
      }
      //return null;
    } else {
      // Handle success results
      //debugPrint(faceResultObj["apiResult"]);
      debugPrint("-----------------apiResult------------------->${faceResultObj["apiResult"]}");
      debugPrint(faceResultObj["imageUri"]);

      HypervergeResponse hyperResponse = HypervergeResponse.fromJson(json.decode(faceResultObj["apiResult"]));
      if(hyperResponse.result.live == "no"){
        //openFaceCaptureScreen(context: context, action: action, formData: formData);
        NavigationUtils.pop(context: context);
        handleBottomSheetAction(
            context,
            WidgetAction(
                api: "Selfie_Error",
                type: "openBotomSheet",
                layoutId: "Selfie_Error"),
            WidgetRepo.layouts,
            "bs-clickaselfieagainerror",
            "");
      }else{
        formData
            .setValue(key: 'liveliness_score', value: '${hyperResponse.result.liveness_score}');
        formData
            .setValue(key: 'liveliness_source', value: 'hyperverge');
        formData
            .setValue(key: action.api, value: faceResultObj["imageUri"]);
      }
    }
  }

  static handleActionAPI(
      {required BuildContext context,
      required String screenId,
      required String response}) {
    SaveSuccess saveSuccess = SaveSuccess.fromJson(jsonDecode(response));
    if (saveSuccess.data?["documents"] != null) {
      print(saveSuccess.data?["documents"]);
      WidgetRepo.documentsData =
          new List<Map<String, dynamic>>.from(saveSuccess.data?["documents"]);
    }

    if (saveSuccess.data?["isESign"] != null) {
      WidgetRepo.isEsign = saveSuccess.data?["isESign"] as bool;
    }

    String navRoute = "/${saveSuccess.action.value.name}";
    NavigationUtils.pushNamed(context: context, route: navRoute);
    lastUserState(saveSuccess.action.value.name, context);
    prefillData(saveSuccess.data ?? {}, context);
  }

  static void prefillData(Map<String, dynamic> data, BuildContext context) {
    data.forEach((key, value) {
      StartupUtils.preFillForm(context: context, key: key, value: value);
    });
  }

  static void lastUserState(String screenName , BuildContext context){
    Provider.of<FormData>(context, listen: false).setValueWithoutNotifi(key: LAST_VISITED, value: screenName);
    if(StartupUtils.screenProgressMap.containsKey(screenName)){
      Provider.of<FormData>(context, listen: false).setValueWithoutNotifi(key: LAST_PROGRESS, value: StartupUtils.screenProgressMap[screenName]);
    }
  }

  static _loaderCall({required String type, required context, id}){
    if((getActionType(type) == WidgetActionTypes.navigateWithAPI ||
        getActionType(type) == WidgetActionTypes.callAPI) && id != null){
      // enabling the Loader in Button CTA
      Provider.of<FormData>(context, listen: false)
          .setValue(key: id + ':loading', value: 'true');
    }
  }

  static handleAction({
    required BuildContext context,
    required String screenId,
    required WidgetAction? action,
    String? id,
    String? analyticID,
    String? analytic_metaData,
  }) {
    Provider.of<FormData>(context, listen: false)
        .setValue(key: 'flow', value: screenId);

    if (action != null) {
      String type = action.type;
      _loaderCall(type: type, context: context,id: id);
      switch (getActionType(type)) {
        case WidgetActionTypes.navigateWithAPI:
          debugPrint("navigation with api , $analyticID and $id");
          handleNavigateWithAPI(
              context: context,
              screenId: screenId,
              action: action,
              id: id,
              analyticId: analyticID ?? "");
          break;
        case WidgetActionTypes.openBotomSheet:
          if(WidgetActionHandler.isBottomsheetOpen){
            Navigator.of(context).pop();
          }
          debugPrint(
              "opening bottom sheet -> $analyticID and ${action.analytic_id} and $analytic_metaData");
          handleBottomSheetAction(
            context,
            action,
            WidgetRepo.layouts,
            analyticID ?? "",
            analytic_metaData ?? "",
          );
          break;
        case WidgetActionTypes.openPanAadhaarSeedBottomsheet:
          String isAadhaarPanSeeded = Provider.of<FormData>(context, listen: false).getValue(key: "isAadhaarPanSeeded") ?? "false";
          debugPrint(
              "opening bottom sheet -> $analyticID and ${action.analytic_id} and $analytic_metaData");
          if(!(isAadhaarPanSeeded.toLowerCase() == "true")) {
            Timer(Duration(milliseconds: 100), () {
              print("Yeah, this line is printed after 3 seconds");
              handleBottomSheetAction(
                context,
                action,
                WidgetRepo.layouts,
                analyticID ?? "",
                analytic_metaData ?? "",
              );
            });
          }
          break;
        case WidgetActionTypes.callAPI:
          debugPrint("callAPI");
          handleNavigateWithAPI(
            context: context,
            screenId: screenId,
            action: action,
            id: id,
            analyticId: analyticID,
          );
          break;
        case WidgetActionTypes.navigateToRoute:
          debugPrint("Navigation to route");
          String navRoute = action.api;
          if (action.others != null) {
            List others = action.others!.split(":");
            navRoute = others.first;
          }
          NavigationUtils.pushNamed(context: context, route: navRoute);
          break;
        case WidgetActionTypes.captureImage:
          captureImage(context: context, action: action, screenId: screenId);
          break;
        case WidgetActionTypes.captureFromGallery:
          captureGalleryImage(
              context: context, action: action, screenId: screenId);
          break;
        case WidgetActionTypes.openCallback:
          debugPrint("handling custom  callback : ${action.api} ");
          callActionCallbacks(action: action, context: context);
          break;
        case WidgetActionTypes.openHyperSnap:
          var formData = Provider.of<FormData>(context, listen: false);
          if(cameraUtil != null) {
            cameraUtil!.dispose();
            Future.delayed(const Duration(milliseconds: 500), () {
              openFaceCaptureScreen(context: context, action: action, formData : formData);
            });
          }else{
            openFaceCaptureScreen(context: context, action: action, formData : formData);
          }
          break;
        case WidgetActionTypes.navigateToHost:
          debugPrint("handling host navigation : ${action.api} ");
          callNative(action.api,context);
          break;
        default:
          debugPrint("===== Handing default action : ${action.api}====== ");
      }
    }
  }

  static bool isCameraInitializing = false;
  static checkCamera(
      {required BuildContext context, required bool isFrontCam}) async {
    if (isCameraInitializing) {
      return;
    }
    isCameraInitializing = true;
    await getCameraUtil()!.setFrontCamera(isFrontCam).then((value) {
      Provider.of<FormData>(context, listen: false)
          .setValue(key: "switchCam", value: "1");
      isCameraInitializing = false;
    });
  }

  static swapCamera({required BuildContext context}) async {
    await getCameraUtil()!.swapCamera().then((value) {
      Provider.of<FormData>(context, listen: false)
          .setValue(key: "switchCam", value: "0");
    });
  }

  static captureGalleryImage(
      {required BuildContext context,
      required WidgetAction action,
      required String screenId}) async {
    debugPrint("CAPTURE ACTION CALLED : ${action.api}");

    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      Permission.storage.request();
    } else {
      await CameraUtil().onCLickPickImageFromGallery().then((value) {
        if(value.isNotEmpty){
          Provider.of<FormData>(context, listen: false)
              .setValue(key: action.api, value: value);

          if(action.api == 'aadhaarFrontLocal' &&
              Provider.of<FormData>(context, listen: false).getValue(key: 'aadhaarBackLocal') != null &&
              Provider.of<FormData>(context, listen: false).getValue(key: 'aadhaarBackLocal').toString().isNotEmpty ){
            NavigationUtils.pushNamed(
                context: context, route: '/aadhar_back');
            NavigationUtils.pushNamed(
                context: context, route: '/aadhar_preview');
          }else{
            NavigationUtils.pushNamed(
                context: context, route: action.postNavigate ?? '');
          }

        }
      });
    }
  }

  static captureImage(
      {required BuildContext context,
      required WidgetAction action,
      required String screenId}) async {
    debugPrint("CAPTURE ACTION CALLED : ${screenId}");

    switch (screenId) {
      case 'signature':
        try {
          ui.Image image =
              await WidgetRepo.signatureKey.currentState!.getData();

          var pngBytes =  await image.toByteData(format: ui.ImageByteFormat.png);
          Directory? directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory();
          String path = directory!.path;
          print(path);

          Directory('$path/Signature').delete(recursive: true);

          await Directory('$path/Signature').create(recursive: true);
          String nameFile = getRandom(5);
          File('$path/Signature/filename' + nameFile + '.png')
              .writeAsBytesSync(pngBytes!.buffer.asInt8List());
          File f = File(path + '/Signature/filename' + nameFile + '.png');

          Provider.of<FormData>(context, listen: false)
              .setValue(key: action.api, value: f.path);
          NavigationUtils.pushNamed(
              context: context, route: action.postNavigate ?? '');
        } catch (e) {
          debugPrint(e.toString());
        }
        break;

      default:
        // await getCameraUtil()!
        //     .onClickGetPANCroppedImage(true, screenId == "selfie")
        //     .then((value) {
        //   Provider.of<FormData>(context, listen: false)
        //       .setValue(key: action.api, value: value);
        //   NavigationUtils.pushNamed(
        //       context: context, route: action.postNavigate ?? '');
        //   checkCameraFlash();
        // });
    }
  }
  static Future<String> captureSignature(
      {required BuildContext context,
        required WidgetAction action,
        required String screenId}) async {
    debugPrint("CAPTURE ACTION CALLED : ${screenId}");

        try {
          ui.Image image =
          await WidgetRepo.signatureKey.currentState!.getData();

          var pngBytes =  await image.toByteData(format: ui.ImageByteFormat.png);
          Directory? directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory();
          String path = directory!.path;
          print(path);

          if(await Directory('$path/Signature').exists()){
             await Directory('$path/Signature').delete(recursive: true);
          }
          print("file exists!! => ${await Directory('$path/Signature').exists()}");
          await Directory('$path/Signature').create(recursive: true);
          String nameFile = getRandom(5);
          File('$path/Signature/filename' + nameFile + '.png')
              .writeAsBytesSync(pngBytes!.buffer.asInt8List());
          File f = File(path + '/Signature/filename' + nameFile + '.png');

          Provider.of<FormData>(context, listen: false)
              .setValue(key: "signatureImageUrl", value: f.path);
          NavigationUtils.pushNamed(
              context: context, route: action.postNavigate ?? '');
          return '';
        } catch (e) {
          debugPrint(e.toString());
          return '';
        }
  }

  static handleNavigateWithAPI({
    required BuildContext context,
    required String screenId,
    required WidgetAction action,
    String? id,
    String? analyticId,
    String? analytic_meta_data,
  }) async {
    debugPrint("== handling api === : " + action.method!);

    var formData = Provider.of<FormData>(context, listen: false);

    String url = action.api;
    var response;
    bool dioCheck = false;
    bool upiCheck = false;
    Map<String, dynamic> formBody =
        buildBody(action: action, formData: formData);
    Map<String, dynamic> formUPIBody =
        buildUPIBody(action: action, formData: formData);
    Map<String, String> formHeaders =
        buildHeaders(action: action, formData: formData);
    Map<String, String> formImageHeaders =
        buildHeadersUpload(action: action, formData: formData);

    fetchNetworkPrefrence(bool isNetworkPresent) {
      if (!isNetworkPresent) {
        formData.clearFlagValue(':loading');
        CustomToast.showToast(context: context, msg : "No Network Available" );
      }
    }

    NetworkCheckHelper.checkInternet(fetchNetworkPrefrence);

    switch (action.method) {
      case 'UPIPOST':
        debugPrint("SEND REQUEST FOR UPI POST API : " + formUPIBody.toString());
        response = await networkClient.postUPI(url: url,body: formUPIBody,headers: formHeaders );

        String requestUrl = appConfig[UPI_URL]+ url;

        String status = "false";
        String msg = "";
        if(response.body != null){
          Map<String,dynamic> valueMap = json.decode(response.body);
          if(valueMap.containsKey("status")){
            if(valueMap["status"] != null){
              status  = valueMap["status"].toString();
            }
          }
          if(valueMap.containsKey("message")){
            if(valueMap["message"] != null){
              msg = valueMap["message"];
            }
          }
        }

        Map<String, dynamic> metadata = {
          "url": requestUrl,
          "status": status,
          "message":msg,
        };

        if(status == 'false'){
          metadata['errorType'] = "Backend";
        }

        AnalyticHelper.logApiEvent(id ?? "", analyticId ?? "", metadata);
        upiCheck=true;
        break;
      case 'GET':
        debugPrint("SEND REQUEST TO GET API : " + formBody.toString());
        response = await networkClient.get(url: url);
        debugPrint("RESPONSE RECEIVED FROM API : " + response.body);
        break;
      case 'GET_DATA':
        debugPrint("SEND REQUEST TO GET API : " + formBody.toString());
        response = await networkClient.getData(
          url: url,
          headers: formHeaders,
          action: action,
          mFormData: formData,
        );
        debugPrint("RESPONSE RECEIVED FROM API : " + response.body);
        break;
      case 'POST':
        debugPrint("SEND REQUEST TO POST API : " + jsonEncode(formBody));
        if(url == "/v1/kyc/bank"){
          handleBottomSheetAction(
              context,
              WidgetAction(
                  api: "Bank_Verification",
                  type: "openBotomSheet",
                  layoutId: "Bank_Verification"),
              WidgetRepo.layouts,
              'bs-bankaccverification',
              'we are verifying your bank acc details');
          NativeAnalyticsHelper.shared.logEventWith(["firebase", "clevertap", "appsflyer"],'Bank_Account_Verification_Screen_Load', 'bank_account_verification_screen_load', context);
        }
        response = await networkClient.post(
            url: url, body: jsonEncode(formBody), headers: formHeaders);
        debugPrint("RESPONSE RECEIVED FROM API : " + response.body);
        break;
      case 'POSTIMAGE':
        debugPrint("SEND REQUEST TO POSTIMAGE API : and $analyticId" +
            jsonEncode(formBody));
        response = await networkClient.postImage(
            url: url,
            action: action,
            mFormData: formData,
            headers: formImageHeaders,
            context: context,
            id: id,
            analyticID: analyticId!);

        SaveSuccess saveSuccessmodel = SaveSuccess.fromJson((response));
        // debugPrint(
        //     'response is ${response["status"]} and ${response["action"]}');

        Map<String, dynamic> metadata = {
          "url": url,
          "status": 'success',
           "message":"${saveSuccessmodel.action.type} to ${saveSuccessmodel.action.value.name}",
        };

        AnalyticHelper.logApiEvent(id ?? "", analyticId, metadata);

        debugPrint(
            "RESPONSE RECEIVED FROM POSTIMAGE API : " + response.toString());
        dioCheck = true;
        break;
      case 'POSTSIGNATURE':
       debugPrint("SEND REQUEST TO POSTSIGNATURE API Rahul Panzade : " + jsonEncode(formBody));
        SaveSuccess saveSuccessmodel;
        await captureSignature(action: action, context: context, screenId: screenId).then((value) async =>
         {
           response = await networkClient.postImage(
               url: url,
               action: action,
               mFormData: formData,
               headers: formImageHeaders,
               context: context,
               id: id,analyticID: analyticId!),

          saveSuccessmodel = SaveSuccess.fromJson((response)),
           AnalyticHelper.logApiEvent(id ?? "", analyticId, {
             "url": appConfig[BASE_URL_KEY] + url,
             "status": 'Success',
             "message":"${saveSuccessmodel.action.type} to ${saveSuccessmodel.action.value.name}}"
           }),

           debugPrint("RESPONSE RECEIVED FROM POSTIMAGE API : " + response.toString()),
           dioCheck = true
         }
         );
        //debugPrint("SEND REQUEST TO POSTSIGNATURE API : " + jsonEncode(formBody));

        break;
      default:
        response = await networkClient.get(url: url);
    }
    if (dioCheck) {
      dioCheck = false;

      // disabling the Loader in Button CTA
      formData.clearFlagValue(':loading');

      SaveSuccess saveSuccess = SaveSuccess.fromJson((response));
      String navRoute = "/${saveSuccess.action.value.name}";
      // if(navRoute=="/bank" && Platform.isAndroid){
      //   if(doUPI && await Contact.getSimInfo != null) navRoute="/bank_UPI";
      // }
        if (saveSuccess.data?["documents"] != null) {
        print(saveSuccess.data?["documents"]);
        WidgetRepo.documentsData =
            new List<Map<String, dynamic>>.from(saveSuccess.data?["documents"]);
      }
      if (saveSuccess.data?["isESign"] != null) {
        WidgetRepo.isEsign = saveSuccess.data?["isESign"] as bool;
      }
      if (saveSuccess.action.value.name == "bankStatement") {
        handleBottomSheetAction(
            context,
            WidgetAction(
              api: "FnO",
              type: "openBotomSheet",
              layoutId: "FnO",
            ),
            WidgetRepo.layouts,
            "bs-activatederivatives",
            "");
        NativeAnalyticsHelper.shared.logEventWith(["firebase","clevertap"],'KYC_Activate_Derivatives_Screen_Load', 'kyc_activate_derivatives_screen_load', context);
      } else {
        NavigationUtils.pushNamed(context: context, route: navRoute);
      }
      prefillData(saveSuccess.data ?? {}, context);
      lastUserState(saveSuccess.action.value.name, context);
      return;
    }

    if(upiCheck){
      if (isBottomsheetOpen) {
        NavigationUtils.pop(context: context);
      }
      if(response.body!=null) {
        var result=jsonDecode(response.body);

        if (result['status'] && url == "/upibank/get_bank_account_detail") {
          SaveUPIBank saveSuccess = SaveUPIBank.fromJson(
              jsonDecode(response.body));
          if (saveSuccess.data != null)
            if (saveSuccess.data!.isNotEmpty) {
              print(saveSuccess.data);
              WidgetRepo.upiUserBankList.addAll(saveSuccess.data!);
            }
          debugPrint(
              "UPI Bank LIST -----> ${WidgetRepo.upiUserBankList.toString()}");
            if(WidgetRepo.upiUserBankList.length == 1){
              formData.setValueWithoutNotifi(key: "btn_link", value: "true");
              formData.setValueWithoutNotifi(key: "bankAccountNumber", value: WidgetRepo.upiUserBankList[0]["account_number"]??"");
              formData.setValueWithoutNotifi(key: "ifsc", value: WidgetRepo.upiUserBankList[0]["account_ifsc"]??"");
              formData.setValueWithoutNotifi(key: "bankFullName", value: WidgetRepo.upiUserBankList[0]["account_holder"]??"");
              formData.setValueWithoutNotifi(key: "bankName", value: WidgetRepo.upiUserBankList[0]["account_bank"]??"");
            }
          NavigationUtils.pushNamed(
              context: context, route: action.postNavigate ?? '');
          formData.setValue(key: "user_banklist", value: response.toString());
        } else if (result['status'] && url == "/upibank/get_bank_list") {

          SaveUPIBank saveSuccess = SaveUPIBank.fromJson(
              jsonDecode(response.body));
          if (saveSuccess.data != null)
            if (saveSuccess.data!.isNotEmpty) {
              print(saveSuccess.data);
              WidgetRepo.otherBank.addAll(saveSuccess.data!);
            }
          // NavigationUtils.pushNamed(
          //     context: context, route: action.postNavigate ?? '');
          formData.setValue(key: "user_banklist", value: response.toString());
        } else {

          if(url == "/upibank/get_bank_account_detail"){

            apiFailedUPI = apiFailedUPI + 1;

            if (apiFailedUPI > 2) {
              apiFailedUPI = 0;
                handleBottomSheetAction(
                  context,
                  WidgetAction(
                      api: "UPI_BANKACC_FAIL_BS",
                      type: "openBotomSheet",
                      layoutId: "UPI_BANKACC_FAIL_BS"),
                  WidgetRepo.layouts,
                  'bs-somethingisntright',
                  '',
                );

            } else {
              handleBottomSheetAction(
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

          }else{
            upiFailMoveToBank(context: context);
          }
        }
      }else{
        upiFailMoveToBank(context: context);
      }

      return;
    }

    debugPrint("Response Received !!!! at handler ${response.statusCode}");
    String requestUrl = appConfig[BASE_URL_KEY] + url;
    switch (response.statusCode) {
      case 200:

        // disabling the Loader in Button CTA
        formData.clearFlagValue(':loading');

        Map<String, dynamic> obj = jsonDecode(response.body);

        if (obj.containsKey(RECORDS)) {
          List<Map<String, dynamic>> dataList =
              _handleBankandBranchDetails(response.body);
          formData.setValue(key: action.queryParameters![ID]!, value: dataList);
          Map<String, dynamic> metadata = {
            "url": requestUrl,
            "status": 'success',
            "message": 'bank/branch/ifsc results',
          };

          debugPrint('record SaveSuccess id is $id and $analyticId');
          AnalyticHelper.logApiEvent(action.queryParameters!['search'] ?? "", analyticId ?? "", metadata);
        }
        else {
          SaveSuccess saveSuccess =
              SaveSuccess.fromJson(jsonDecode(response.body));

          debugPrint('saveSuccess.data is ${saveSuccess.data}');
          lastUserState(saveSuccess.action.value.name , context);
          //done it for analytic part
          if(saveSuccess.data != null){
            prefillData(saveSuccess.data!, context);
            Map <String,dynamic> temp_mapdata = saveSuccess.data ?? {};

            String kraname = '';
            String isKra = 'no';
            //debugPrint('temp_mapdata -> $temp_mapdata');
            if(temp_mapdata.isNotEmpty){
              if(temp_mapdata.containsKey('kraFullName')){
                if(temp_mapdata['kraFullName'] != null){
                  kraname = temp_mapdata['kraFullName'] ?? "";
                }
              }
              if(temp_mapdata.containsKey('isKRA')){
                if(temp_mapdata['isKRA'] != null){
                  isKra = temp_mapdata['isKRA'] == true ? 'yes': 'no';
                }
              }

            }

            //debugPrint('kraname and isKra $kraname and $isKra');
            formData.setValueWithoutNotifi(key: 'kraname', value: kraname);
            formData.setValueWithoutNotifi(key: 'isKra', value: isKra);
          }


          if (saveSuccess.data?["documents"] != null) {
            print(saveSuccess.data?["documents"]);
            WidgetRepo.documentsData = new List<Map<String, dynamic>>.from(
                saveSuccess.data?["documents"]);
            //WidgetRepo.documentsData = saveSuccess.data?["documents"] as List<Map<String,dynamic>>;
          }

          if(url == "/v1/kyc/bank") {
            formData.setValueWithoutNotifi(key:'imps_analytic' , value: 'no');
            if(WidgetActionHandler.isBottomsheetOpen){
              Navigator.pop(context);
            }
            if (obj["data"]["imps"] as bool == true) {
              formData.setValueWithoutNotifi(key:'imps_analytic' , value: 'yes');

              Map<String, dynamic> metadata = {
                "url": requestUrl,
                "status": saveSuccess.status,
                "message":
                    "${saveSuccess.action.type} to ${saveSuccess.action.value.name}",
              };

              AnalyticHelper.logApiEvent(id ?? "", analyticId ?? "", metadata);

              handleBottomSheetAction(
                  context,
                  WidgetAction(
                      api: "Bank_Acc_linked",
                      type: "openBotomSheet",
                      layoutId: "Bank_Acc_linked"),
                  WidgetRepo.layouts,
                  'bs-bankacclinked',
                  'we have verifyied your bank acc details');
              NativeAnalyticsHelper.shared.logEventWith(["firebase","clevertap"],'Bank_Account_Linked_Screen_Load', 'bank_account_linked_screen_load', context);
              Future.delayed(const Duration(milliseconds: 1000), () {
                NavigationUtils.pushNamed(
                    context: context,
                    route: "/${saveSuccess.action.value.name}");
              });
            } else {
              Map<String, dynamic> metadata = {
                "url": requestUrl,
                "status": 'fail',
                "message":
                    "account number is invalid please try with some other account",
                "errorType": "Backend"
              };

              AnalyticHelper.logApiEvent(id ?? "", analyticId ?? "", metadata);
              handleBottomSheetAction(
                context,
                WidgetAction(
                    api: "PennyDrop_Edit_Bank",
                    type: "openBotomSheet",
                    layoutId: "PennyDrop_Edit_Bank"),
                WidgetRepo.layouts,
                'bs-accnoisinvalid',
                '',
              );
              
              NativeAnalyticsHelper.shared.logEventWith(["firebase","clevertap"],'Account_Number_Invalid_Screen_Load', 'account_number_invalid_screen_load', context);
            }
          } else {
            Map<String,dynamic>? temp = saveSuccess.data;
            Map<String, dynamic> metadata = {
              "url": requestUrl,
              "status": saveSuccess.status,
              "message":
                  "${saveSuccess.action.type} to ${saveSuccess.action.value.name}",
              "errorType": "Backend"
            };

            AnalyticHelper.logApiEvent(id ?? "", analyticId ?? "", metadata);
            String navRoute = "/${saveSuccess.action.value.name}";
            // if(navRoute=="/bank" && Platform.isAndroid){
            //   if(doUPI && await Contact.getSimInfo != null) navRoute="/bank_UPI";
            // }
            NavigationUtils.pushNamed(context: context, route: navRoute);
          }
        }

        break;
      case 500:
      case 400:
        // disabling the Loader in Button CTA
        formData.clearFlagValue(':loading');

        HttpError saveError = HttpError.fromJson(jsonDecode(response.body));
        CustomToast.showToast(context: context, msg: saveError.message);
        Map<String, dynamic> metadata = {
          "url": requestUrl,
          "status": 'fail',
          "message": saveError.message,
          "errorType": "Backend"
        };
        AnalyticHelper.logApiEvent(id!, analyticId!, metadata);
        if(WidgetActionHandler.isBottomsheetOpen){
          Navigator.pop(context);
        }
        break;
      default:
        if(WidgetActionHandler.isBottomsheetOpen){
          Navigator.pop(context);
        }
        // disabling the Loader in Button CTA
        formData.clearFlagValue(':loading');
        break;
    }
  }

  static void upiSkipCall({required BuildContext context}){
    WidgetActionHandler.handleAction(
        context: context,
        screenId: "currentScreen",
        action: WidgetAction(
            api: "/v1/kyc/skip/bank/upi",
            type: "navigateWithAPI",
            method: "POST",
            bodyParameters: {
            }),
        id: 'submit',
        analyticID: "bs-couldnotfindacc",
        analytic_metaData: "");
  }

  static void upiFailMoveToBank({required BuildContext context}){
    doUPI=false;
    upiSkipCall(context: context);
  }

  static List<Map<String, dynamic>> _handleBankandBranchDetails(dynamic obj) {
    BankBranchList list = BankBranchList.fromJson(jsonDecode(obj));
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
    //debugPrint('data is $data');
    return data;
  }

  static Future<void> getAutoPickedUpAndroidResult(
      {context: Context,
      screenId: String,
      analyticid: String,
      analytic_meta_Data: String}) async {
    if (screenId == "email" &&
        Platform.isAndroid &&
        FormData().getValue(key: "AutoPickedEmailHardCodeKey") != "true") {
      FormData().setValue(key: "AutoPickedEmailHardCodeKey", value: "true");
      try {
        var result = await Contact
            .getEmails;
        String pickedResult = result.toString();
        if (pickedResult == 'none') {
          debugPrint(
              'email auto pick bottom sheet $analyticid and $analytic_meta_Data');
          WidgetActionHandler.handleAction(
              context: context,
              screenId: screenId,
              action: WidgetAction(
                  api: "email", type: "openBotomSheet", layoutId: "Email"),
              analyticID: 'bs-enterotheremail',
              analytic_metaData: 'Email address:email,button:email_submit');
          Future.delayed(Duration(milliseconds: 100), () {
            PersistedFormController.getFocusNode('email').requestFocus();
          });
        } else if (pickedResult != 'null') {
          StartupUtils.preFillForm(
              context: context, key: 'email', value: pickedResult);

          AnalyticHelper.logClickEvent(
            analyticID: 'p-googlemail',
            component: SELECT,
            id: 'email',
            metaData: {'Email address':pickedResult}
          );

          WidgetActionHandler.handleAction(
              context: context,
              screenId: screenId,
              action: WidgetAction(
                  api: "email", type: "openBotomSheet", layoutId: "Email"),
              analyticID: 'bs-enterotheremail',
              analytic_metaData: 'Email address:email,button:email_submit');
        } else if (pickedResult == 'null') {
          FormData()
              .setValue(key: "AutoPickedEmailHardCodeKey", value: "false");
        }

        print(result.runtimeType);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }

  static handleBottomSheetAction(
    BuildContext context,
    WidgetAction action,
    final Map<String, List<List<Layout>>>? layouts,
    String? analyticID,
    String? analytic_meta_data,
  ) {
    debugPrint("======== HANDLING BOTOM SHEET =======");
    debugPrint(
        'analytic id in BOTOM sheet $analyticID and $analytic_meta_data ');
    debugPrint(
        "======== HANDLING BOTOM SHEET ======= ${action.type} ${action.analytic_id} and ${action.layoutId} and ${action.layout}");
    if(action.layoutId == "BackDoItLater"){
      NativeAnalyticsHelper.shared.logEventWith(["firebase","clevertap"],'KYC_Want_to_Leave_Screen_Load', 'kyc_want_to_leave_screen_load', context);
    }
    String analyticid = '';
    String analyticMetadata = '';
    if (analyticID != null) {
      if (analyticID != 'no_log') {
        analyticid = analyticID;
        analyticMetadata = analytic_meta_data ?? "";
        bool isLogImpressionEvent = true;
        if (action.analytic_id != null) {
          if (action.analytic_id!.toLowerCase() == 'no') {
            isLogImpressionEvent = false;
          } else {
            analyticid = action.analytic_id ?? "";
            analyticMetadata = action.analytic_event_metadata ?? "";
          }
        }

        bool isLogClickEvent = false;
        // if (action.layoutId != null) {
        //   isLogClickEvent = true;
        //   isLogImpressionEvent = false;
        // }

        if (analyticID == 'onback') {
          isLogImpressionEvent = true;
          isLogClickEvent = false;
        }

        debugPrint(
            'isLogImpressionEvent in bottom $isLogImpressionEvent and $isLogClickEvent and $analyticid and $analyticMetadata');

        if (isLogImpressionEvent) {
          AnalyticHelper.logImpressionEvent(
              screenname: analyticid,
              type: action.type,
              metaData: analyticMetadata.length > 0 ? analyticMetadata : "");
        }

        if (isLogClickEvent)
          AnalyticHelper.logClickEvent(
            analyticID: analyticid,
            component: TEXT,
            id: action.layoutId!.toLowerCase(),
          );
      }
    }

    debugPrint(
        'analyticid before showModalBottomSheet method is $analyticid and $kDebugMode');

    int bottomIndex = PersistedFormController.navIndex++;


    if (action.layoutId != "Email") {
      //Future.delayed(Duration(milliseconds: 300), () {
        WidgetActionHandler.isBottomsheetOpen = true;
      //});
    }
    showModalBottomSheet(
      elevation: 1,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => kDebugMode
          ? bottomSheetWidget(
              context: ctx,
              action: action,
              layouts: layouts,
              bottomIndex: bottomIndex,
              analyticID: analyticid,
              analytic_event_metaData: analyticMetadata,
            )
          : ChangeNotifierProvider<FormData>(
              create: (context) => FormData(),
              child: bottomSheetWidget(
                context: ctx,
                action: action,
                layouts: layouts,
                bottomIndex: bottomIndex,
                analyticID: analyticid,
                analytic_event_metaData: analyticMetadata,
              ),
            ),
    ).whenComplete(() {
      WidgetActionHandler.isBottomsheetOpen = false;
      FormData().setValue(key: "mobile_check", value: 'true');
      if (action.api == 'email') {
        FormData().setValue(
            key: "AutoPickedEmailHardCodeKey", value: 'false');
          getAutoPickedUpAndroidResult(context: context, screenId: 'email');
      }else{
        Provider.of<FormData>(context, listen: false).setValue(key: 'UI', value: "update");
      }
    });

    if (action.api == 'email' && Platform.isAndroid && FormData().getValue(key: "AutoPickedEmailHardCodeKey") != "true") {
      FormData().setValue(
          key: "AutoPickedEmailHardCodeKey", value: 'true');
      Future.delayed(Duration(milliseconds: 100), () {
        PersistedFormController.getFocusNode('email').requestFocus();
      });
    }
  }



  static AnimatedPadding bottomSheetWidget({required BuildContext context,required Map<String, List<List<Layout>>>? layouts,required WidgetAction action,required int bottomIndex,String? analyticID, String? analytic_event_metaData}) {
    return AnimatedPadding(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 32.0, horizontal: 16.0),
              child: Form(
                  key: PersistedFormController.getFormKeys(bottomIndex),
                  child: DynamicLayout(screenId: action.api,layout: action.layout ?? layouts![action.layoutId]!,screenIndex: bottomIndex,analyticID: analyticID,analytic_metaData: analytic_event_metaData,)),
            ),
          )
        ],
      ),
    );
  }

  static void callActionCallbacks(
      {required WidgetAction action, required BuildContext context}) {
    debugPrint("======== callActionCallbacks ======= : " + action.api);
    return ActionCallbacks.runCallback(
        method: action.api,
        context: context,
        params: (action.bodyParameters != null) ? (action.bodyParameters) : {});
  }

  static void callNative(String method,BuildContext context) {

    AnalyticHelper.forcePushdata();

    if (getNavigatorPlugin() == null) {
       initializeNavigator();
    }

    var formData = Provider.of<FormData>(context, listen: false);
    var flow=formData.getValue(key: 'flow');

    Map<String, String> objectToNative = {};
    objectToNative['isSignUpCompleted'] = (flow=='thanks')?'true':'false';
    objectToNative['isExplore_Guide'] = (flow=='thanks')?'true':'false';
    objectToNative['isExplore_Myself'] = (flow=='email')?'true':'false';
    objectToNative['mobile_number'] = formData.getValue(key: 'mobile')??"";
    objectToNative['client_name'] = formData.getValue(key: 'fullName')??"";
    objectToNative['appNumber'] = formData.getValue(key: 'appNumber')??"";
    objectToNative['screenName'] = formData.getValue(key: LAST_VISITED )??"";
    objectToNative['journeyProgress'] = formData.getValue(key: LAST_PROGRESS)??"";

    if(flow =='thanks'){
      NativeAnalyticsHelper.shared.logEventWith(["firebase", "clevertap", "appsflyer"],'Confirmation', 'confirmation_screen_load', context);
    }

    if (WidgetActionHandler.futterToFlutterCallback != null) {
      WidgetActionHandler.futterToFlutterCallback!(objectToNative);
    }else {
      _navigatorPlugin?.dataToNativeWithHandler(method, objectToNative);
      _navigatorPlugin?.close();
    }
    // SystemNavigator.pop();
  }

  static void sendAnalyticDataToNative(Map<String,dynamic> data,BuildContext context) {
    if (getNavigatorPlugin() == null) {
      initializeNavigator();
    }
     _navigatorPlugin?.dataToNativeWithHandler("pushAnalytics", data);
  }
  static Map<String, String> buildHeaders(
      {required WidgetAction action, required FormData formData}) {
    Map<String, String> headers = {
      'Authorization': 'Bearer ${formData.getValue(key: 'token')}',
    };
    if (action.headerParameters != null) {
      action.headerParameters?.forEach((key, value) {
        if (formData.getValue(key: value) != null) {
          headers[key] = formData.getValue(key: value);
        }
      });
    }
    return headers;
  }

  static Map<String, dynamic> buildBody(
      {required WidgetAction action, required FormData formData}) {
    Map<String, dynamic> body = {
      "appNumber": formData.getValue(key: 'appNumber'),
      "flow": formData.getValue(key: 'flow'),
      "id": formData.getValue(key: 'actionId'),
    };
    Map<String, dynamic> data = {};
    debugPrint("BODY : " + action.bodyParameters.toString());
    action.bodyParameters?.forEach((key, value) {
      data[key] = formData.getValue(key: value)??value;
    });
    body["data"] = data;
    return body;
  }

  static Map<String, dynamic> buildUPIBody(
      {required WidgetAction action, required FormData formData}) {
    Map<String, dynamic> body = {
    };
    action.bodyParameters?.forEach((key, value) {
      body[key] = formData.getValue(key: value)??value;
    });
    return body;
  }

  static Map<String, String> buildHeadersUpload(
      {required WidgetAction action, required FormData formData}) {
    Map<String, String> headers = {
      "Content-Type": "multipart/form-data",
    };
    return headers;
  }

  static String getRandom(int length) {
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  static List<String> getImageList(
      {required List<String> imageResID, required FormData formData}) {
    List<String>? sampleImage = [];
    imageResID.forEach((element) {
      sampleImage.add(formData.getValue(key: element) ?? "");
    });
    return sampleImage;
  }


  static List<Map<String, dynamic>> getSelectedBankList({required FormData formData}) {

    List<Map<String, dynamic>> upiUserBankList=[
      {
        "account_ifsc":formData.getValue(key: "ifsc")??"",
        "account_holder":formData.getValue(key: "bankFullName")??"",
        "account_number":formData.getValue(key: "bankAccountNumber")??"",
        "account_bank":formData.getValue(key: "bankName")??""
      }
    ];
    return upiUserBankList;
  }

  static String getBankIcon({required String bankName}) {
    switch (bankName) {
      case "ICICI Bank":
        return "icici.png";
      case "HDFC BANK LTD":
        return "hdfc.png";
      case "Axis Bank":
        return "axis.png";
      case "State Bank Of India":
        return "sbi.png";
      default:
        return "bank.png";
    }
  }

  static datePicker(BuildContext context, FormData formData, String id, String dateFormat) async {
    var date = DateTime.now();
    var preFilled = PersistedFormController.getTextEditingController(id).text;
    var initialDate = DateTime(date.year - 18, date.month , date.day);
    if(preFilled.isNotEmpty){
      var array = preFilled.split("/");
      initialDate = DateTime(int.parse(array[2]),int.parse(array[1]),int.parse(array[0]));
    }
    formData.setValue(key: id, value: '');
    final picked = await showDatePicker(
      locale: const Locale('en', 'IN'),
      context: context,
      initialDate: initialDate, // Refer step 1
      firstDate: DateTime(date.year - 108, date.month , date.day),
      lastDate: DateTime(date.year - 18, date.month , date.day),
      helpText: "SELECT DATE OF BIRTH",
      cancelText: "CANCEL",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: (Theme.of(context).brightness == Brightness.light)
              ? ThemeData.light()
              : ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      // setState(() {
      // var dateButtonName = '${picked.day}/${picked.month}/${picked.year}';
      var dateButtonName = DateFormat(dateFormat).format(picked);
      // });
      formData.setValue(key: id, value: dateButtonName);
      PersistedFormController.getTextEditingController(id).text =
          dateButtonName;
    }
  }
}
