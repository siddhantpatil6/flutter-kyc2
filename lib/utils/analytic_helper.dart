import 'package:analytic_plugin/analytic_plugin.dart';
import 'package:flutter/material.dart';
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/utils/config_utils.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/widget_repo.dart';


class AnalyticHelper {
  static AnalyticHelper? _instance;
  AnalyticHelper._();
  static AnalyticHelper get instance => _instance ??= AnalyticHelper._();

  static String flowValue = '';
  static String _journeyid = '';
  static bool isDigilocker = false;

  static Map<String,dynamic> _getmetadata(){

    bool issignupload = false;
    bool isselfieupload = false;
    bool isbankstmtupload = false;
    bool ispanupload = false;
    bool isaadhaarupload = false;
    bool isbankchequeupload = false;

    if(WidgetRepo.documentsData != null){
      WidgetRepo.documentsData?.forEach((element) {
           Map<String,dynamic> temp = element;
           debugPrint('temp dict is $temp');
           if(temp['name'] == 'PAN Card'){
             ispanupload = temp['uploaded'] ?? false;
           }
           if(temp['name'] == 'Selfie'){
             isselfieupload = temp['uploaded'] ?? false;
           }
           if(temp['name'] == 'Signature'){
             issignupload = temp['uploaded'] ?? false;
           }
           if(temp['name'] == 'Aadhaar'){
             isaadhaarupload = temp['uploaded'] ?? false;
           }
           if(temp['name'] == 'Bank Statement'){
             isbankstmtupload = temp['uploaded'] ?? false;
           }
           if(temp['name'] == 'Bank Cheque'){
             isbankchequeupload = temp['uploaded'] ?? false;
           }
      });

    }


    Map<String,dynamic> temp = {
      "aadhaarNo":FormData().getValue(key: "aadhaar"),
      "applicationNo":FormData().getValue(key: "appNumber"),
      "beneficiaryName":"",
      "isBasicNameMatch":"",
      "isCkyc":"",
      "isCvlKra":"",
      "isIpv":"",
      "isIpvRequired":"",
      "nsdlName":"",
      "kraName": FormData().getValue(key: 'kraname') ?? '',
      "isImps": FormData().getValue(key: 'imps_analytic') ?? 'no',
      "isKra": FormData().getValue(key: 'isKra') ?? 'no',
      "isKraComplaint": FormData().getValue(key: 'isKra') ?? 'no',
      "isDigilocker":isDigilocker.toString(),
      "isEsign":WidgetRepo.isEsign.toString(),
      "isSignatureUploaded":issignupload.toString(),
      "isPanUploaded":ispanupload.toString(),
      "isSelfieUploaded":isselfieupload.toString(),
      "isAadhaarUploaded":isaadhaarupload.toString(),
      "isBankStatementUploaded":isbankstmtupload.toString(),
      "isBankchequeUploaded":isbankchequeupload.toString(),
      "isPush":"false",
      "message":"success",
    };

    //debugPrint('temp is $temp');

    return temp;
  }

  static Map<String, dynamic> _getDataFromNative() {
    debugPrint('flow value is $flowValue');

    // aadhaarOCRConfirmation = true - select_OCR
    _journeyid = 'select_Manual';
    isDigilocker = false;
    if (flowValue == 'digilocker') {
      _journeyid = 'select_Digilocker';
      isDigilocker =  true;
    }

    Map<String, dynamic> data = {
      'user_id': {
        'app_id': ConfigSingleTon.instance.configData?.appId ?? '',
        'auc': '',
        'clevertap_id': ConfigSingleTon.instance.configData?.cleverTapId ?? '',
        'appsflyer_id': ConfigSingleTon.instance.configData?.appsFlyerId ?? '',
        'gtm_id': ConfigSingleTon.instance.configData?.tvcClientId ?? '',
        'analytics_kyc_id': ConfigSingleTon.instance.configData?.uuid ?? '',
        'kyc_platform':
            ConfigSingleTon.instance.configData?.platform, //'uat_cug',
        'journey_id': _journeyid,
      },
      'session_id': ConfigSingleTon.instance.configData?.guestToken ?? '',
      'device_token': ConfigSingleTon.instance.configData?.device ?? '',
      'release_code': ConfigSingleTon.instance.configData?.releaseCode ?? '',
      'build_release': ConfigSingleTon.instance.configData?.buildRelease ?? '',
      'client_ip': ConfigSingleTon.instance.configData?.ipAddress ?? '',
      'pipe_topic':
          ConfigSingleTon.instance.configData?.pipeTopic ?? _getPipeToken(),
    };
    return data;
  }

  static String _getPipeToken() {

    if(ConfigSingleTon.instance.configData?.envType.toString().toLowerCase() == "prod"){
      return (ConfigSingleTon.instance.configData?.platform.toLowerCase() ==
          'android')
          ? 'spark_android'
          : 'spark_ios';
    }
    else{
      return 'uat_cug';
    }

  }

  static void forcePushdata(){
    AnalyticPlugin.forcePushRequest();
  }

  static void setURLandOtherDetails() {

    String url  = appConfig[ANALYTIC_URL_KEY];//ConfigSingleTon.instance.configData?.envType.toString().toLowerCase() == "prod" ? ANALYTIC_PROD_URL : ANALYTIC_UAT_URL;
    AnalyticPlugin.setAnalyticURLandOtherdetails(
        url: url, buffer_size: 10, buffer_time: 30);
  }

  static void logImpressionEvent(
      {String screenname = '',
      String type = '',
      String metaData = '',
      String idvalue = ''}) {
    debugPrint('logImpressionEvent is $screenname and $type and $metaData');
    String metadata = metaData.contains("screen") ? metaData : "";

    if (getEvenIDBasedOnAnalyticID(screenname).length > 0) {
      AnalyticPlugin.logEvent(
        screenname: screenname,
        eventtype: IMPRESSION,
        eventsubtype: ((type.length > 0) && (type == OPENBOTTOMSHEET))
            ? BOTTOMSHEET
            : (type == POPUP) ? POPUP : SCREEN,
        eventname: screenname,
        eventid: getEvenIDBasedOnAnalyticID(screenname),
        eventmetadata:

        getmetaDataBasedOnAnalyticID(screenname, idvalue).length > 0
                ?
                 {
                    'message_body':
                        "${getmetaDataBasedOnAnalyticID(screenname, idvalue)}, $metadata "
                  }
                :  (screenname == WE_RECEIVED_DOCUMENTS) ? _getmetadata()
                    :
        {},

        nativeData: _getDataFromNative(),
      );
    }
  }

  static void logClickEvent(
      {String analyticID = '',
      String component = '',
      String id = '',
      String flowvalue = '',
        String eventid='',
        String eventname = '',
      Map<String, dynamic>? metaData}) {
    debugPrint(
        'logClickEvent flowvalue -> $id $flowvalue $analyticID and $metaData');

    // debugPrint(
    //     'getEventNameandIDBaseOnID(id, analyticID, component, flowvalue)-> ${getEventNameandIDBaseOnID(id, analyticID, component, flowvalue)}');

    if (getEventNameandIDBaseOnID(id, analyticID, component, flowvalue).length >
        0) {
      if (getMetaDataBasedOnFlow(analyticID, flowvalue).length > 0) {
        List data = getMetaDataBasedOnFlow(analyticID, flowvalue).split(":");
        metaData![data.first.toString()] = data.last.toString();
      }

      if (analyticID != 'no_log') {
        debugPrint(
            'analytic id in not no_log $analyticID and ${analyticID.length}');
        if (analyticID.length > 0) {
          AnalyticPlugin.logEvent(
            screenname: analyticID,
            eventtype: CLICK,
            eventsubtype: (component.toLowerCase() == TEXTFIELD) ||
                    (component.toLowerCase() == TEXT)
                ? (component.toLowerCase() == TEXT)
                    ? TEXT
                    : TEXTFIELD
                : (component.toLowerCase() == CARD) ||
                        (component.toLowerCase() == SELECT)
                    ? CARD
                    : (component.toLowerCase() == SELECT)
                        ? SELECT
                        : (component.toLowerCase() == CHECKBOX)
                            ? CHECKBOX
                            : (component.toLowerCase() == BUTTON ) ? BUTTON :
            (component.toLowerCase() == DROPDOWN )  ?  DROPDOWN: (component.toLowerCase() == RADIO_BUTTON) ? RADIO_BUTTON :USERINPUTFIELD,

            eventname: (eventname.length > 0) ? eventname :
                getEventNameandIDBaseOnID(id, analyticID, component, flowvalue)
                    .split(":")
                    .first,
            eventid: (eventid.length > 0) ? eventid :
                getEventNameandIDBaseOnID(id, analyticID, component, flowvalue)
                    .split(":")
                    .last,
            eventmetadata: (metaData != null) ? metaData : {},
            nativeData: _getDataFromNative(),
          );
        } else {
          List datalist =
              getEventNameandIDBaseOnID(id, analyticID, component, flowvalue)
                  .split(":");
          int mid_index = (datalist.length ~/ 2).toInt();
          debugPrint('datalist in else is $datalist and midindex $mid_index');
          if (datalist.length == 3) {
            AnalyticPlugin.logEvent(
              screenname: getEventNameandIDBaseOnID(
                      id, analyticID, component, flowvalue)
                  .split(":")
                  .first,
              eventtype: CLICK,
              eventsubtype: (component.toLowerCase() == TEXTFIELD) ||
                      (component.toLowerCase() == TEXT)
                  ? (component.toLowerCase() == TEXT)
                      ? TEXT
                      : TEXTFIELD
                  : (component.toLowerCase() == CARD) ||
                          (component.toLowerCase() == SELECT)
                      ? CARD
                      : (component.toLowerCase() == SELECT)
                          ? SELECT
                          : (component.toLowerCase() == CHECKBOX)
                              ? CHECKBOX
                              : BUTTON,
              eventname: datalist[mid_index],
              eventid: getEventNameandIDBaseOnID(
                      id, analyticID, component, flowvalue)
                  .split(":")
                  .last,
              eventmetadata: (metaData != null) ? metaData : {},
              nativeData: _getDataFromNative(),
            );
          }
        }
      }
    }
  }

  static void logBackPressEvent(
      String screenID, String analyticID, String backOption) {
    if (getEventIDBaseOnScreenID(screenID).length > 0) {
      AnalyticPlugin.logEvent(
        screenname: analyticID,
        eventtype: CLICK,
        eventsubtype: ICON,
        eventname: BACK,
        eventid: getEventIDBaseOnScreenID(screenID),
        eventmetadata: {'BackType': backOption},
        nativeData: _getDataFromNative(),
      );
    }
  }

  static String getMetaDataBasedOnFlow(String analyticID, String flowvalue) {
    switch (analyticID) {
      case BS_DO_YOU_WANT_TO_LEAVE:
        return 'screen:$flowvalue';
      // case CLICK_SELFIE:
      //   return 'message:Click a Selfie';
      default:
        return '';
    }
  }

  static String getEventIDBaseOnScreenID(String screenIDvalue) {
    switch (screenIDvalue) {
      case 'register':
        return '73.0.0.2.1';
      case 'email':
        return '73.0.0.3.1';
      case 'pan':
        return '73.0.0.6.1';
      case 'panUpload':
        return '73.0.0.6.1';
      case 'panManual':
        return '73.0.0.10.2';
      case 'bank_main':
        return '73.0.0.11.1';
      case 'bank':
        return '73.0.0.11.9';
      case 'selfie':
        return '73.0.0.24.1';
      case 'is_aadhaar_link_to_mobile':
        return '73.0.0.19.1';
      case 'aadhar':
        return '73.0.0.20.1';
      case 'aadhar_front_input':
        return '73.0.0.60.21';
      case 'aadhar_back_input':
        return '73.0.0.60.21';
      case 'digilocker':
        return '73.0.0.22.1';
      case 'income':
        return '73.0.0.25.3';
      case 'occupation':
        return '73.0.0.26.4';
      case 'personal':
        return '73.0.0.27.1';
      case 'signature':
        return '73.0.0.28.1';
      case 'appointment':
        return '73.0.0.30.1';
      case 'aadhaar_main':
        return '73.0.0.33.1';
      case 'aadhar_back':
        return '73.0.0.34.1';
      case 'bankCheque':
        return '73.0.0.37.1';
      case 'search_bank_and_branch':
        return '73.0.0.60.6';
      case 'pan_preview':
        return '73.0.0.60.8';
      case 'pan_input_camera':
        return '73.0.0.60.12';
      case 'panUpload_input_camera':
        return '73.0.0.60.12';
      case 'pan_preview_error':
        return '73.0.0.60.16';
      case 'aadhar_back_input':
        return '73.0.0.60.21';
      case 'aadhar_front_input':
        return '73.0.0.60.21';
      case 'aadhar_preview':
        return '73.0.0.60.27';
      case 'signature_camera':
        return '73.0.0.60.39';
      case 'bankStatement':
        return '73.0.0.60.40';
      case 'cheque_preview':
        return '73.0.0.60.44';
      case 'hypersnap_selfie':
        return '73.0.0.60.34';
      case 'bankUPI':
        return '73.0.0.11.1';
      case 'upi_user_banklist':
        return '73.0.0.60.67';
      default:
        return '';
    }
  }

  static String getEventNameandIDBaseOnAPIcall(
      String idvalue, String analyticID) {
    idvalue = '$idvalue&$analyticID';
    debugPrint(
        'idvalue is getEventNameandIDBaseOnAPIcall $idvalue and $analyticID');

    if (flowValue.toLowerCase() == 'panocrconfirmation' ||
        flowValue.toLowerCase() == 'panUploadOCRConfirmation') {
      return 'PANvalidationapi:73.0.0.6.10';
    }

    if (flowValue.toLowerCase() == 'confirm_signature') {
      if (idvalue == 'signature_submit&') {
        return 'signsubmitapi:73.0.0.60.52';
      }
    }

    switch (idvalue) {
      case 'register_submit&s-enteryourmobileno':
        return 'mobilevalidationapi:73.0.0.2.7';
      case 'email_submit&bs-enterotheremail':
        return 'Emailvalidationapi:73.0.0.5.2';
      case 'panImageUrl&bs-uploadpancard':
        return 'PANuploadapi:73.0.0.9.4';
      case 'btn_link&s-linkyourbankacc':
        return 'Banksenddetailsapi:73.0.0.11.15';
      case 'bank_name_main&s-searchifsc':
        return 'SearchIFSC-BankBranchapi:73.0.0.14.3';
      case 'branch_name_main&s-searchifsc':
        return 'SearchIFSC-BankBranchapi:73.0.0.14.3';
      case 'ifsc&s-addbankdetailsmanual':
        return 'SearchIFSC-BankBranchapi:73.0.0.14.3';
      case 'aadhaar_submit&s-enteraadhardetails':
        return 'SendAddressdetailsapi:73.0.0.20.4';
      case 'personal_submit&s-genderandmaritalstatus':
        return 'Proceedapirequest:73.0.0.27.5';
      case 'submit&s-signyourapplication':
        return 'Esign-getxmlapi:73.0.0.42.4';
      case 'bank_statement&bs-uploadyour6monthbankstatement':
        return 'SendPOAdetailsapi:73.0.0.38.13';
      case 'submit&bs-uploadyour6monthbankstatement':
        return 'SendPOAdetailsapi:73.0.0.38.13';
      case 'submit_pan_preview&s-uploadpancard':
        return 'PANvalidationapi:73.0.0.6.10';
      case 'pan_submit&s-enteryourpandetails':
        return 'PANvalidationapi:73.0.0.6.10';
      case 'submit_pan_preview&s-panpreview':
        return 'panocrvalidation:73.0.0.60.9';
      case 'pan_upload_submit&s-panpreview':
        return 'panocrvalidation:73.0.0.60.9';
      case 'submit_bank&s-addbankdetailsmanual':
        return 'Bankdetailssubmit:73.0.0.60.14';
      case 'submit&s-aadharpreview':
        return 'aadharocrvalidation:73.0.0.60.29';
      case 'aadhaar_confirmation_submit&s-uploadaadharcard':
        return 'aadharconfirmvalidation:73.0.0.60.32';
      case 'cheque_confirmation_submit&s-uploadcancelledcheque':
        return 'confirmcancelledcheque:73.0.0.60.48';
      case 'bank_cheque_submit&s-cancelledchequepreview':
        return 'uploadcancelledcheque:73.0.0.60.47';
      case 'bankChequeImageUrl&bs-uploadcancelledcheque':
        return 'uploadcancelledcheque:73.0.0.60.47';
      case 'selfie_submit&s-selfiecheckandconfirm':
        return 'selfiecheckandconfirm:73.0.0.60.49';
      case 'appointment_submit&s-pickaslot':
        return 'confirmslot:73.0.0.60.51';
      case 'signature_pad&s-signyourapplication':
        return 'signsubmitapi:73.0.0.60.52';
      case 'income_submit&s-annualincome':
        return 'incomeapi:73.0.0.25.4';
      case 'occupation_submit&s-employmentype':
        return 'employmentTypeapi:73.0.0.26.5';
      case 'next&bs-verifyyournumber':
        return 'getbankaccdetails:73.0.0.60.66';
      case 'next1&bs-verifyyournumber':
       return 'getbanklist:73.0.0.60.73';
      case 'btn_link&s-linkyourbankaccdetail':
        return 'bankverfication:73.0.0.60.65';
      case 'submit&bs-couldnotfindacc':
        return 'skipapi:73.0.0.60.76';
      case 'submit&bs-somethingisntright':
        return 'skipapi:73.0.0.60.76';
      default:
        return '';
    }
  }

  static String getEventNameandIDBaseOnID(
      String idvalue, String analyticID, String component, String flowvalue) {
    List data = analyticID.split('-');

    // FormData? formData;
    // String flowvalue = formData!.getValue(key: 'flow');

    debugPrint('flow value is $flowvalue');

    idvalue = '$idvalue&$analyticID';
    debugPrint(
        'idvalue is getEventNameandIDBaseOnID $idvalue and $data and ${data.length} and $component');

    if (data.length == 1) {
      //others
      debugPrint(
          'idvalue is others in click $idvalue and $data and ${data.length} and $component');
      if (flowvalue == 'pan_input_camera') {
        if (idvalue == 'panImageUrl&') {
          if (component == BUTTON) {
            return 's-uploadpancard:capture:73.0.0.6.5';
          }
        }
      } else if (flowvalue == 'pan_preview_error') {
        if (idvalue == 'panImageUrl&') {
          if (component == CARD) {
            return 's-uploadpancard:clickagain:73.0.0.6.8';
          }
        }
        if (idvalue == 'submit_pan_preview&') {
          return 's-uploadpancard:tryagain:73.0.0.6.6';
        } else if (idvalue == 'submit&') {
          return 's-uploadpancard:adddetailsmanually:73.0.0.6.7';
        }
      } else if (flowValue == 'panOCRConfirmation' ||
          flowValue == 'panUploadOCRConfirmation') {
        if (idvalue == 'pan_confirmation_submit&' ||
            idvalue == 'pan_upload_confirmation_submit&') {
          return 's-uploadpancard:confirm:73.0.0.6.9';
        } else if (idvalue == 'click_again&') {
          return 's-uploadpancard:click again:73.0.0.6.8';
        }
      } else if (flowValue == 'aadhar_front_input') {
        if (idvalue == 'aadhaarFrontLocal&') {
          return 's-uploadfrontaadharcard:capture:73.0.0.33.5';
        }
      } else if (flowValue == 'aadhar_back_input') {
        if (idvalue == 'aadhaarBackLocal&') {
          return 's-uploadbackaadharcard:capture:73.0.0.34.5';
        }
      } else if (flowValue == 'aadhar_preview') {
        if (idvalue == 'submit&') {
          if (component == TEXT)
            return 's-uploadaadharcard:enterdetailsmanually:73.0.0.36.1';
          if (component == BUTTON) return '';
        }
        // } else if (flowValue == 'signature_camera') {
        //   if (idvalue == 'signatureImageUrl&') {
        //     return 's-signyourapplication:capture:73.0.0.28.6';
        //   } else if (idvalue == 'submit&') {
        //     return 's-signyourapplication:uploadafile:73.0.0.28.7';
        //   }
      } else if (flowValue == 'confirm_signature') {
        if (idvalue == 'signature_submit&') {
          return 's-signyourapplication:submit:73.0.0.28.4';
        } else if (idvalue == 'signature_checkbox&') {
          return 's-signyourapplication:iamnotapoliticallyexposed:73.0.0.28.3';
        } else if (idvalue == 'submit&') {
          return 's-signyourapplication:startover:73.0.0.28.2';
        }
      }
      // else if (flowValue == 'cheque_preview') {
      //   if (idvalue == 'bank_cheque_submit&') {
      //     if (component == ROUND_BUTTON) {
      //       return 's-uploadcancelledcheque:capture:73.0.0.37.5';
      //     }
      //   }
      //
      // }
      else if (flowValue == 'cheque_input_camera') {

        if (idvalue == 'bankChequeImageUrl&') {
            return 's-uploadcancelledcheque:capture:73.0.0.37.5';
          //return 's-uploadcancelledcheque:clickagain:73.0.0.37.9';
        }
        else if (idvalue == 'submit&') {
          return 's-uploadcancelledcheque:uploadfromgallery:73.0.0.37.6';
        }

      }
    } else {
      //screen
      if (data.first.toString().toLowerCase() == 's') {
        if(flowValue == 'hypersnap_selfie'){
          if (idvalue == '&s-clickaselfie') {
            return 'capture:73.0.0.24.2';
          }
        }
        if (flowvalue != 'pan_preview_error') {
          if (idvalue == 'submit&s-uploadpancard') {
            if (component == TEXT) {
              return 'uploadafile:73.0.0.6.4';
            } else if (component == BUTTON) {
              return 'clickapicture:73.0.0.6.3';
            }
            // else if (component == ROUND_BUTTON) {
            //   return 'capture:73.0.0.6.5';
            // }
          }
          // if (idvalue == 'pan_confirmation_submit&s-uploadpancard') {
          //   return 'confirm:73.0.0.6.9';
          // }
        }

        if (idvalue == 'ifsc&s-addbankdetailsmanual') {
          if (component == TEXT) {
            return 'searchifsc:73.0.0.11.11';
          }
          if (component == TEXTFIELD) {
            return 'ifsccode:73.0.0.50.11';
          }
        }

        if (idvalue == 'submit&s-signyourapplication') {
          if (component == TEXT) {
            if (flowvalue == 'signature_camera' ||
                flowvalue == 'confirm_signature ') {
              return 'uploadafile:73.0.0.28.7';
            }
          }
        }

        if (idvalue == 'signature_pad&s-signyourapplication') {
          if (component == TEXT) {
            // if (flowvalue == 'signature_camera') {
            //   return 'uploadafile:73.0.0.28.7';
            // } else
            if (flowvalue == 'signature') {
              return 'startover:73.0.0.28.2';
            }
          }
          if (component == BUTTON) {
            return 'submit:73.0.0.28.4';
          }
          // if (component == ROUND_BUTTON) {
          //   return 'capture:73.0.0.28.6';
          // }
        }

        if (idvalue == 'submit&s-uploadfrontaadharcard') {
          if (component == TEXT) {
            return 'uploadafile:73.0.0.33.4';
          }
          if (component == BUTTON) {
            return 'clickapicture:73.0.0.33.3';
          }
          // if (component == ROUND_BUTTON) {
          //   return 'capture:73.0.0.33.5';
          // }
        }

        if (idvalue == 'submit&s-uploadbackaadharcard') {
          if (component == TEXT) {
            return 'uploadafile:73.0.0.34.4';
          }
          if (component == BUTTON) {
            return 'clickapicture:73.0.0.34.3';
          }
          // if (component == ROUND_BUTTON) {
          //   return 'capture:73.0.0.34.5';
          // }
        }
        if (idvalue == 'aadhaar_confirmation_submit&s-uploadaadharcard') {
          // if (component == TEXT) {
          //   return 'enterdetailsmanually:73.0.0.36.1';
          // }
          if (component == BUTTON) {
            return 'confirm:73.0.0.36.3';
          }
        }
        if (idvalue == 'submit&s-uploadcancelledcheque') {
          if (component == BUTTON) {
            // if (flowvalue == 'cheque_preview') {
            //   return 'clickapicture:73.0.0.37.10';
            // }
            return 'clickapicture:73.0.0.37.3';
          }
          if (component == TEXT) {
            return 'uploadfromgallery:73.0.0.37.4';
          }
          // if (component == ROUND_BUTTON) {
          //   return 'capture:73.0.0.37.5';
          // }
        }

        /*if (flowvalue == 'pan_preview_error') {
          if (idvalue == 'panImageUrl&s-uploadpancard') {
            if (component == CARD) {
              return 'clickagain:73.0.0.6.8';
            }
          }
          if (idvalue == 'submit_pan_preview&s-uploadpancard') {
            return 'tryagain:73.0.0.6.6';
          } else if (idvalue == 'submit&s-uploadpancard') {
            return 'adddetailsmanually:73.0.0.6.7';
          }
        }*/

        if (flowValue == 'panUpload_input_camera') {
          if (idvalue == 'submit&s-pancamera') {
            return '';
          }
        }

        if (flowValue == 'aadhar_preview') {
          if (idvalue == 'submit&s-aadharpreview') {
            if (component == BUTTON) {
              return 'confirm:73.0.0.60.26';
            }
            return 'enterdetailsmanually:73.0.0.60.28';
          }
        }

        if(flowValue == 'panManual'){
          if(idvalue == 'dob&s-enteryourpandetails'){
            if(component == TEXTFIELD){
              return 'dob:73.0.0.50.6';
            }
            else if(component == ICON){
              return 'dobcalendar:73.0.0.60.53';
            }
          }
        }

        if(flowValue == 'bankUPI'){
          if(idvalue == 'bank_dropdown&s-linkyourbankacc'){
            if(component == TEXTFIELD){
                return 'searchbank:73.0.0.60.75';
            }
            else if(component == DROPDOWN){
              return 'otherbanks:73.0.0.11.8';
            }
          }
        }

        switch (idvalue) {
          case 'mobile&s-enteryourmobileno':
            return 'mobileno:73.0.0.50.1';
          case 'fullName&s-enteryourmobileno':
            return 'yourfullname:73.0.0.50.3';
          case 'referralCode&s-enteryourmobileno':
            return 'referallcode:73.0.0.50.4';
          case 'lastSpaceBetween&s-enteryourmobileno':
            return 'termsandconditions:73.0.0.2.3';
          case 'register_submit&s-enteryourmobileno':
            return 'next:73.0.0.2.5';
          case 'Google_btn&s-addyouremailaddress':
            return 'google:73.0.0.3.2';
          case 'other_btn&s-addyouremailaddress':
            return 'otheremail:73.0.0.3.4';
          case 'submit&s-addyouremailaddress':
            return 'trytheappfirst:73.0.0.3.5';
          case 'pan_help&s-uploadpancard':
            return 'needhelp:73.0.0.6.2';
          case 'panImageUrl&s-uploadpancard':
            return 'clickagain:73.0.0.6.8';
          case 'submit_pan_preview&s-uploadpancard':
            return 'confirm:73.0.0.6.9';
          case 'pan&s-enteryourpandetails':
            return 'permanentaccno:73.0.0.50.5';
          case 'panFatherName&s-enteryourpandetails':
            return 'fathersname:73.0.0.50.7';
          case 'dob&s-enteryourpandetails':
            return 'dob:73.0.0.50.6';
          case 'pan_submit&s-enteryourpandetails':
            return 'submit:73.0.0.10.1';
          case 'bank_help&s-addbankdetailsmanual':
            return 'needhelp:73.0.0.11.10';
          case 'clickableText&s-linkyourbankacc':
            return 'adddetailsmanually:73.0.0.11.3';
          case 'selectBankOptionCard&s-linkyourbankacc':
            return 'bank:73.0.0.11.13';
          // case 'bank_dropdown&s-linkyourbankacc':
          //   return 'searchbank:73.0.0.60.75';
          case 'bankAccountNumber&s-linkyourbankaccdetail':
            return 'bank:73.0.0.11.13';
          case 'btn_link&s-linkyourbankaccdetail':
            return 'linkyourbankacc:73.0.0.11.14';
          case 'btn_link_1&s-linkyourbankaccdetail':
            return 'continue:73.0.0.60.71';
          case 'submit&s-linkyourbankaccdetail':
            return 'editbankdetails:73.0.0.60.72';
          case 'bankAccountNumber&s-addbankdetailsmanual':
            return 'bankaccno:73.0.0.50.9';
          case 'confirmBankAccountNumber&s-addbankdetailsmanual':
            return 'confirmbankaccno:73.0.0.50.10';
          case 'bank_name_main&s-searchifsc':
            return 'bankname :73.0.0.14.1';
          case 'branch_name_main&s-searchifsc':
            return 'branchname:73.0.0.14.2';
          case 'submit&s-clickaselfie':
            return 'opencamera:73.0.0.60.30';
          case 'Yes&s-kycverificationaadhar':
            return 'yes:73.0.0.19.2';
          case 'No&s-kycverificationaadhar':
            return 'no:73.0.0.19.3';
          case 'aadhaar_front_help&s-enteraadhardetails':
            return 'needhelp:73.0.0.20.2';
          case 'aadhaar_submit&s-enteraadhardetails':
            return 'submit:73.0.0.20.3';
          case 'aadhaar&s-enteraadhardetails':
            return 'aadharnoscan:73.0.0.60.31';
          case 'addressLine1&s-enteraadhardetails':
            return 'address1:73.0.0.50.12';
          case 'addressLine2&s-enteraadhardetails':
            return 'address2:73.0.0.50.13';
          case 'addressLine3&s-enteraadhardetails':
            return 'address3:73.0.0.50.14';
          case 'pincode&s-enteraadhardetails':
            return 'pincode:73.0.0.50.15';
          case 'income_submit&s-annualincome':
            return 'next:73.0.0.25.2';
          case 'income&s-annualincome':
            return 'annualincome:73.0.0.25.1';
          case 'occupation&s-employmentype':
            return 'employmentype:73.0.0.26.1';
          case 'occupation_submit&s-employmentype':
            return 'next:73.0.0.26.3';
          case 'occupationOthersSpecification&s-employmentype':
            return '';
          case 'whatsappNotifications&s-employmentype':
            return 'getupdatesviawhatsapp:73.0.0.26.2';
          case 'gender&s-genderandmaritalstatus':
            return 'gender:73.0.0.27.2';
          case 'maritalStatus&s-genderandmaritalstatus':
            return 'maritalstatus:73.0.0.27.3';
          case 'personal_submit&s-genderandmaritalstatus':
            return 'proceed:73.0.0.27.4';
          case 'signature_pad&s-signyourapplication':
            return 'startover:73.0.0.28.2';
          case 'signature_checkbox&s-signyourapplication':
            return 'iamnotapoliticallyexposed:73.0.0.28.3';
          case 'submit&s-wehavereciveddocuments':
            return 'exploreapp:73.0.0.32.1';
          case 'aadhaar_front_help&s-uploadfrontaadharcard':
            return 'needhelp:73.0.0.33.2';
          case 'aadhaar_back_help&s-uploadbackaadharcard':
            return 'needhelp:73.0.0.34.2';
          case 'aadhaarFrontUrl&s-uploadaadharcard':
            return 'clickagain:73.0.0.36.2';
          case 'aadhaarBackUrl&s-uploadaadharcard':
            return 'clickagain:73.0.0.36.2';
          case 'aadhaar&s-uploadaadharcard':
            return 'aadharnoscan:73.0.0.60.31';
          case 'addressLine1&s-uploadaadharcard':
            return 'address1scan:73.0.0.50.18';
          case 'addressLine2&s-uploadaadharcard':
            return 'address2scan:73.0.0.50.19';
          case 'state&s-uploadaadharcard':
            return 'statescan:73.0.0.50.22';
          case 'city&s-uploadaadharcard':
            return 'cityscan:73.0.0.50.20';
          case 'pincode&s-uploadaadharcard':
            return 'pincodescan:73.0.0.50.21';
          case 'cheque_help&s-uploadcancelledcheque':
            return 'needhelp:73.0.0.37.2';
          case 'bankChequeImageUrl&s-uploadcancelledcheque':
            return 'clickagain:73.0.0.37.9';
          case 'bankAccountNumber&s-uploadcancelledcheque':
            return 'accnumberscan:73.0.0.50.24';
          case 'ifsc&s-uploadcancelledcheque':
            return 'ifsccodescan:73.0.0.50.25';
          case 'bankstatement_help&s-uploadyour6monthbankstatement':
            return 'needhelp:73.0.0.39.2';
          case 'submit&s-uploadyour6monthbankstatement':
            return 'uploadbankstatement:73.0.0.39.3';
          case 'signatureImageUrl&s-signyourapplication':
            return 'capture:73.0.0.28.6';
          case 'signature_pad_click&s-signyourapplication':
            return 'clickapicture:73.0.0.28.5';
          case 'click_again&s-panpreview':
            return 'tryagain:73.0.0.60.5';
          case 'submit_pan_preview&s-panpreview':
            return 'confirm:73.0.0.60.7';
          case 'pan_upload_submit&s-panpreview':
            return 'confirm:73.0.0.60.7';
          case 'submit_bank&s-addbankdetailsmanual':
            return 'submit:73.0.0.11.12';
          case 'appointment_submit&s-pickaslot':
            return 'confirmappointment:73.0.0.30.2';
          case 'click_again&s-uploadcancelledcheque':
            return 'clickagain:73.0.0.37.9';
          case 'cheque_confirmation_submit&s-uploadcancelledcheque':
            return 'confirm:73.0.0.37.10';
          case 'pan_help&s-pancamera':
            return 'needhelp:73.0.0.60.13';
          case 'panImageUrl&s-pancamera':
            return 'capture:73.0.0.60.11';
          case 'submit&s-pancaptureerror':
            return 'adddetailsmanually:73.0.0.60.18';
          case 'submit_pan_preview&s-pancaptureerror':
            return 'tryagain:73.0.0.60.17';
          case 'submit&s-aadharcamera':
            return 'uploadfile:73.0.0.60.22';
          case 'aadhaarFrontLocal&s-aadharcamera':
            return 'capture:73.0.0.60.20';
          case 'aadhaarBackLocal&s-aadharcamera':
            return 'capture:73.0.0.60.20';
          case 'aadhaarFrontLocal&s-aadharpreview':
            return 'clickagainfront:73.0.0.60.24';
          case 'aadhaarBackLocal&s-aadharpreview':
            return 'clickagainback:73.0.0.60.25';
          case 'hyperSnapId&s-selfiecheckandconfirm':
            return 'clickanotherselife:73.0.0.60.36';
          case 'selfie_submit&s-selfiecheckandconfirm':
            return 'confirmandupload:73.0.0.60.35';
          case 'click_again&s-cancelledchequepreview':
            return 'clickagain:73.0.0.60.42';
          case 'bank_cheque_submit&s-cancelledchequepreview':
            return 'confirm:73.0.0.60.43';
          case 'signatureImageUrl&s-signaturecamera':
            return 'capture:73.0.0.60.38';
          case 'submit&s-signaturecamera':
            return 'uploadfromgallery:73.0.0.60.50';
          case 'clickableText&s-linkyourbankacc':
            return 'adddetailsmanually:73.0.0.11.3';
          case 'hdfc bank ltd&s-linkyourbankacc':
            return 'hdfc:73.0.0.11.4';
          case 'icici bank&s-linkyourbankacc':
            return 'icici:73.0.0.11.5';
          case 'state bank of india&s-linkyourbankacc':
            return 'sbi:73.0.0.11.7';
          case 'axis bank&s-linkyourbankacc':
            return 'axis:73.0.0.11.6';
          // case 'bank_dropdown&s-linkyourbankacc':
          //   return 'otherbanks:73.0.0.11.8';
          case 'bank_help&s-linkyourbankacc':
            return 'needhelp:73.0.0.11.2';

          default:
            return '';
        }
      }

      //bottomsheet
      if (data.first.toString().toLowerCase() == 'bs') {
        if (idvalue == 'panImageUrl&bs-uploadpancard') {
          if (component == TEXT) {
            return 'enterdetailsmanually:73.0.0.9.3';
          } else if (component == CARD) {
            return 'uploadpan:73.0.0.9.1';
          } else if (component == BUTTON) {
            return 'tryagain:73.0.0.9.5';
          }
        }

        if (idvalue == 'bankChequeImageUrl&bs-uploadcancelledcheque') {
          if (component == CARD) {
            return 'upload:73.0.0.38.1';
          } else if (component == TEXT) {
            return 'uploadlater:73.0.0.60.46';
          } else if (component == BUTTON) {
            return 'tryagain:73.0.0.38.4';
          }
        }

        if (idvalue == 'submit&bs-doyouwanttoleave') {
          if (component == TEXT) {
            return 'doitlater:73.0.0.7.2';
          } else if (component == BUTTON) {
            return 'continuewithkyc:73.0.0.7.1';
          }
        }

        if(idvalue == 'submit_edit&bs-doyouwanttoleave'){
          return 'editbankdetails:73.0.0.7.3';
        }

        if (idvalue == 'submit&bs-accnoisinvalid') {
          //debugPrint('log component is $component');
          if (component == BUTTON) {
            return 'tryanotheraccno:73.0.0.60.1';
          } else if (component == TEXT) {
            return 'uploadcancelledcheque:73.0.0.60.2';
          }
        }

        if(idvalue == 'submit&bs-Panaadharlinking'){
          if (component == BUTTON) {
            return 'linkyourpan:73.0.0.60.69';
          }
          return 'cancel:73.0.0.60.70';
        }

        if(idvalue == 'submit&bs-couldnotfindacc'){
          if (component == BUTTON) {
            return 'tryanothermobileno:73.0.0.18.1';
          } else if (component == TEXT) {
            return 'enterdetailsmanually:73.0.0.18.2';
          }
        }

        if(idvalue == 'submit&bs-somethingisntright'){
          if (component == BUTTON) {
            return 'tryagain:73.0.0.17.1';
          } else if (component == TEXT) {
            return 'enterdetailsmanually:73.0.0.17.2';
          }
        }

        if(idvalue == 'mobile&bs-verifyyournumber'){
          if(component == TEXTFIELD){
            return 'mobileno:73.0.0.50.8';
          }
          return 'editnumber:73.0.0.13.1';

        }


        switch (idvalue) {
          case 'email&bs-enterotheremail':
            return 'emailaddress:73.0.0.50.26';
          case 'email_submit&bs-enterotheremail':
            return 'next:73.0.0.4.1';
          case 'Yes&bs-activatederivatives':
            return 'yes:73.0.0.29.1';
          case 'No&bs-activatederivatives':
            return 'no:73.0.0.29.2';
          case 'slot_picker&bs-pickaslot':
            return 'timeslot:73.0.0.31.1';
          case 'bank_statement&bs-uploadyour6monthbankstatement':
            return 'upload:73.0.0.40.1';
          case 'submit&bs-uploadyour6monthbankstatement':
            return 'submit:73.0.0.40.2';
          case 'submit&bs-clickaselfieagainerror':
            return 'opencamera:73.0.0.60.63';
          case 'sim_radio&bs-verifyyournumber':
            return 'sim:73.0.0.13.3';
          case 'next&bs-verifyyournumber':
            return 'next:73.0.0.13.2';
          default:
            return '';
        }
      }

      //popup
      if(data.first.toString().toLowerCase() == 'p'){
        switch (idvalue) {
          case 'dob&p-dobcalendar':
            return 'ok:73.0.0.60.57';
          case 'email&p-googlemail':
            return 'emailid:73.0.0.5.1';
          default:
            return '';
        }

      }
    }

    return '';
  }

  static String getmetaDataBasedOnAnalyticID(
      String analyticID, String idvalue) {
    switch (analyticID) {
      case ADD_YOUR_EMAIL_ADDRESS:
        return 'Add your email address to';
      case BS_NEED_HELP_PAN:
        return 'PAN card guidelines';
      case BS_NEED_HELP_AADHAAR:
        return 'aadhar card guidelines';
      case BS_DO_YOU_WANT_TO_LEAVE:
        return 'Do you want to leave without completing KYC?';
      case AADHAAR:
        return 'Kyc verfication via aadhar';
      case UPLOAD_PAN_CARD:
        return 'progress:15%';
      case PAN_CAMERA:
        return 'keep your pan card within the frame';
      case AADHAAR_CAMERA:
        return 'keep the card within the frame';
      case PAN_PREVIEW_ERROR:
        return 'couldnt click picture';
      case PAN_PREVIEW:
        return 'progress:15%';
      case LINK_YOUR_BANK_ACCOUNT:
        return 'progress:35%';
      case LINK_YOUR_BANK_ACCOUNT_DETAIL:
        return 'we have found this bank';
      case ENTER_AADHAAR_DETAILS:
        return 'progress:65%';
      case UPLOAD_FRONT_AADHAAR_CARD:
        return 'progress:65%';
      case UPLOAD_BACK_AADHAAR_CARD:
        return 'progress:65%';
      case UPLOAD_CANCEL_CHEQUE:
        return 'progress:65%';
      case UPLOAD_BANK_STATEMENT:
        return 'progress:65%';
      case CLICK_SELFIE:
        return 'progress:75%';
      case SIGN_YOUR_APPLICATION:
        return 'progress:80%';
      case ANNUAL_INCOME:
        return 'progress:90%';
      case EMPLOYMENT_TYPE:
        return 'progress:92%';
      case SIGNATURE_CAMERA:
        return 'sign on a white paper and click a picture';
      case BS_INVALID_ACCOUNT_ID:
        return 'please enter a valid saving bank acc';
      case BS_BANK_ACCOUNT_VERIFICATION:
        return 'we are verifying your bank acc details';
      case BS_BANK_ACCOUNT_LINKED:
        return 'we are verifying your bank acc details';
      case BS_SOMETHING_NOT_RIGHT:
        return 'there was a problem';
      case BS_COULD_NOT_FIND_MOBILE:
        return 'we couldnt able to use mobile number';
      case AADHAAR_PREVIEW:
        return 'progress:65%';
      case SELFIE_CHECK_CONFIRM:
        return 'check and confirm';
      case BS_CLICK_SELFIE_AGAIN_ERROR:
        return 'click your selfie again';
      case BS_NEED_HELP_BANK_DETAILS:
        return 'Bank Details guidelines';
    }

    return '';
  }

  static String getEvenIDBasedOnAnalyticID(String analyticID) {
    switch (analyticID) {
      case ENTER_YOUR_MOBILE_NUMBER:
        return '73.0.0.2.0';
      case ADD_YOUR_EMAIL_ADDRESS:
        return '73.0.0.3.0';
      case ADD_BANK_DETAILS_MANUAL:
        return '73.0.0.60.3';
      case BS_ENTER_OTHER_EMAIL_ADDRESS:
        return '73.0.0.4.0';
      case UPLOAD_PAN_CARD:
        return '73.0.0.6.0';
      case PAN_CAMERA:
        return '73.0.0.60.10';
      case AADHAAR_CAMERA:
        return '73.0.0.60.19';
      case PAN_PREVIEW_ERROR:
        return '73.0.0.60.15';
      case PAN_PREVIEW:
        return '73.0.0.60.4';
      case CANCEL_CHEQUE_PREVIEW:
        return '73.0.0.60.41';
      case BS_DO_YOU_WANT_TO_LEAVE:
        return '73.0.0.7.0';
      case BS_UPLOAD_PAN_CARD:
        return '73.0.0.9.0';
      case BS_NEED_HELP_PAN:
        return '73.0.0.8.0';
      case BS_NEED_HELP_AADHAAR:
        return '73.0.0.21.0';
      case BS_UPLOAD_CANCEL_CHEQUE:
        return '73.0.0.38.0';
      case ENTER_YOUR_PAN_DETAILS:
        return '73.0.0.10.0';
      case LINK_YOUR_BANK_ACCOUNT:
        return '73.0.0.11.0';
      case SEARCH_IFSC:
        return '73.0.0.14.0';
      case CLICK_SELFIE:
        return '73.0.0.24.0';
      case SIGNATURE_CAMERA:
        return '73.0.0.60.37';
      case AADHAAR:
        return '73.0.0.19.0';
      case AADHAAR_PREVIEW:
        return '73.0.0.60.23';
      case ENTER_AADHAAR_DETAILS:
        return '73.0.0.20.0';
      case DIGILOCKER:
        return '73.0.0.22.0';
      case ANNUAL_INCOME:
        return '73.0.0.25.0';
      case EMPLOYMENT_TYPE:
        return '73.0.0.26.0';
      case GENDER_MARITAL_STATUS:
        return '73.0.0.27.0';
      case SIGN_YOUR_APPLICATION:
        return '73.0.0.28.0';
      case BS_ACTIVATE_DERIVATIVE:
        return '73.0.0.29.0';
      case PICK_SLOT:
        return '73.0.0.30.0';
      case BS_PICK_SLOT:
        return '73.0.0.31.0';
      case WE_RECEIVED_DOCUMENTS:
        return '73.0.0.32.0';
      case UPLOAD_FRONT_AADHAAR_CARD:
        return '73.0.0.33.0';
      case UPLOAD_BACK_AADHAAR_CARD:
        return '73.0.0.34.0';
      case UPLOAD_CANCEL_CHEQUE:
        return '73.0.0.37.0';
      case UPLOAD_BANK_STATEMENT:
        return '73.0.0.39.0';
      case SELFIE_CHECK_CONFIRM:
        return '73.0.0.60.33';
      case LINK_YOUR_BANK_ACCOUNT:
        return '73.0.0.11.0';
      case LINK_YOUR_BANK_ACCOUNT_DETAIL:
        return '73.0.0.60.64';
      case BS_UPLOAD_BANK_STATEMENT:
        return '73.0.0.40.0';
      case BS_INVALID_ACCOUNT_ID:
        return '73.0.0.60.0';
      case BS_BANK_ACCOUNT_VERIFICATION:
        return '73.0.0.15.0';
      case BS_BANK_ACCOUNT_LINKED:
        return '73.0.0.16.0';
      case BS_CLICK_SELFIE_AGAIN_ERROR:
        return '73.0.0.60.62';
      case BS_PAN_AADHAAR_LINK:
        return '73.0.0.60.68';
case BS_VERIFY_YOUR_MOBILE:
return '73.0.0.13.0';
case BS_SOMETHING_NOT_RIGHT:
return '73.0.0.17.0';
case BS_COULD_NOT_FIND_MOBILE:
return '73.0.0.18.0';
case BS_NEED_HELP_BANK_DETAILS:
return '73.0.0.12.0';
      case P_DOBCALENDAR:
        return '73.0.0.60.54';


      default:
        return '';
    }
  }

  static void logApiEvent(
    String id,
    String analyticID,
    Map<String, dynamic>? metaData,
  ) {
    debugPrint('logApiEvent id and analyticID $id and $analyticID');

    if (getEventNameandIDBaseOnAPIcall(id, analyticID).split(":").last.length >
        0) {
      if (flowValue.toLowerCase() == 'aadhaarocrconfirmation') if (metaData !=
          null) {
        if (metaData['status'] != null) {
          _journeyid = (metaData['status'] == 'success')
              ? 'select_OCR'
              : 'select_Manual';
        }
      }
      AnalyticPlugin.logEvent(
        screenname: '',
        eventtype: API,
        eventsubtype: API_REQUEST_RESPONSE,
        eventname:
            getEventNameandIDBaseOnAPIcall(id, analyticID).split(":").first,
        eventid: getEventNameandIDBaseOnAPIcall(id, analyticID).split(":").last,
        eventmetadata: (metaData != null) ? metaData : {},
        nativeData: _getDataFromNative(),
      );
    }
  }
}
