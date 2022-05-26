import 'dart:async';
import 'dart:convert';

import 'package:digilocker/DigilockerWebView.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:esign/ESignWebView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/widgets/bank_option_card.dart';
import 'package:flutter_shared_widgets/widgets/blinking_text.dart';
import 'package:flutter_shared_widgets/widgets/checkbox_with_title.dart';
import 'package:flutter_shared_widgets/widgets/clickable_text.dart';
import 'package:flutter_shared_widgets/widgets/custom_button.dart';
import 'package:flutter_shared_widgets/widgets/custom_camera_widget.dart';
import 'package:flutter_shared_widgets/widgets/custom_captured_image.dart';
import 'package:flutter_shared_widgets/widgets/custom_icon.dart';
import 'package:flutter_shared_widgets/widgets/custom_image.dart';
import 'package:flutter_shared_widgets/widgets/custom_text_button.dart';
import 'package:flutter_shared_widgets/widgets/date_field_widget.dart';
import 'package:flutter_shared_widgets/widgets/document_upload_widget.dart';
import 'package:flutter_shared_widgets/widgets/dropdown.dart';
import 'package:flutter_shared_widgets/widgets/dropdown_with_searchbar.dart';
import 'package:flutter_shared_widgets/widgets/gif_animation_widget.dart';
import 'package:flutter_shared_widgets/widgets/horizontal_options.dart';
import 'package:flutter_shared_widgets/widgets/info_widget.dart';
import 'package:flutter_shared_widgets/widgets/input_text.dart';
import 'package:flutter_shared_widgets/widgets/label.dart';
import 'package:flutter_shared_widgets/widgets/option_personal_select.dart';
import 'package:flutter_shared_widgets/widgets/option_select.dart';
import 'package:flutter_shared_widgets/widgets/option_select_card.dart';
import 'package:flutter_shared_widgets/widgets/otp_component.dart';
import 'package:flutter_shared_widgets/widgets/progress_header.dart';
import 'package:flutter_shared_widgets/widgets/round_button.dart';
import 'package:flutter_shared_widgets/widgets/signature_box.dart';
import 'package:flutter_shared_widgets/widgets/slot_button.dart';
import 'package:flutter_shared_widgets/widgets/slot_picker_list.dart';
import 'package:flutter_shared_widgets/widgets/swipable_images.dart';
import 'package:flutter_shared_widgets/widgets/text_field_overlay_widget.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:intl/intl.dart';
import 'package:kyc2/analytics/native_analytic_helper.dart';
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/utils/config_utils.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/navigation_utils.dart';
import 'package:kyc2/utils/startup_utils.dart';
import 'package:kyc2/utils/theme_helper.dart';
import 'package:kyc2/widgets/numbered_list.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'debounce.dart';

getKeyboardType(String type) {
  switch (type) {
    case "number":
      return InputFieldKeyboardtype.number;
    case "text":
      return InputFieldKeyboardtype.text;
    case "email":
      return InputFieldKeyboardtype.email;
    case "phone":
      return InputFieldKeyboardtype.phone;
    default:
      return InputFieldKeyboardtype.text;
  }
}

class WidgetRepo {
  static Debounce _debounce = Debounce(Duration(milliseconds: 400));
  static GlobalKey<SignatureState> signatureKey = GlobalKey<SignatureState>();
  static Map<String, List<List<Layout>>>? layouts;
  static List<Map<String, dynamic>>? documentsData;
  static List<Map<String, dynamic>> upiUserBankList=[];
  static bool isEsign = false;
  static String isErrorOnDataPress =  '';
  static bool isDualSim =  false;
  static List<Map<String, dynamic>> otherBank = [];
  static List<Map<String, dynamic>> dynamic_list = [];
  static Widget getWidget(
    BuildContext context,
    String currentScreen,
    int screenIndex,
    String analyticID,
    String analytic_metaData,
    String id,
    String widgetName, {
    Params? params,
    Map<String, dynamic>? validation,
    WidgetStyle? style,
    WidgetAction? action,
    required FormData formData,
    required Layout layout,
  }) {
    /*
      params?
      action?
      validation?"
     */
    // debugPrint(
    //     "---------------------------------------------------------------->$currentScreen");
    // if(currentScreen == 'selfie'){
    //   WidgetRepo._debounce(() {});
    // }
    // Handle visibilty condition
    if (params != null && params.visibleWhen != null) {
      var idFromJson = params.visibleWhen!.split(':').first;
      var valueFromJson = params.visibleWhen!.split(':').last;
      var currentValue = formData.getValue(key: idFromJson);
      if (idFromJson == "ESign") {
        if (currentValue == null && valueFromJson == "true") {
        } else if (currentValue != valueFromJson) {
          return Padding(padding: EdgeInsets.zero);
        }
      } else if (idFromJson == 'nsdlesignlabel') {
        if (valueFromJson == "true" && WidgetRepo.isEsign) {
          return Padding(padding: EdgeInsets.zero);
        } else if (!WidgetRepo.isEsign && valueFromJson == "false") {
          return Padding(padding: EdgeInsets.zero);
        }
      } else if (idFromJson == 'signature_stylus') {
        if (!(signatureKey.currentState?.hasPoints ?? false) &&
            (formData.getValue(key: "signatureImageUrl") != null &&
                formData.getValue(key: "signatureImageUrl") != "")) {
          if(signatureKey.currentState?.hasPoints ?? false){
            formData.setValueWithoutNotifi(key: "signature_pad", value: "${true}");
          }
          debugPrint(
              "signature_stylus -------->${formData.getValue(key: "signatureImageUrl")}====");
          if(formData.getValue(key: "signatureImageUrl") != 'true'){
            return Padding(padding: EdgeInsets.zero);
          }
        }else if((formData.getValue(key: "signatureImageUrl") != null &&
            formData.getValue(key: "signatureImageUrl").toString().isNotEmpty) &&
            formData.getValue(key: "signatureImageUrl") != 'true' ){
          return Padding(padding: EdgeInsets.zero);
        }
      } else if (idFromJson == 'signatureImgUrl'){
        debugPrint(
            "-----------signatureImgUrl-->${formData.getValue(key: "signatureImageUrl")}====");
        if(formData.getValue(key: "signatureImageUrl") == null || formData.getValue(key: "signatureImageUrl") == 'true'
        || formData.getValue(key: "signatureImageUrl").toString().isEmpty ){
          return Padding(padding: EdgeInsets.zero);
        }
      } else if (idFromJson == 'signature_pad' ||  idFromJson == 'signature_pad'){
        if(signatureKey.currentState?.hasPoints ?? false || formData.getValue(key: 'signature_pad') == 'true' ||
            (formData.getValue(key: "signatureImageUrl") != null && formData.getValue(key: "signatureImageUrl").toString().isNotEmpty)){
        }else{
          return Padding(padding: EdgeInsets.zero);
        }
      } else if (currentValue == 'true') {
      } else if (valueFromJson != currentValue) {
        return Padding(padding: EdgeInsets.zero);
      }
      /*
      * 1. extract key and value
      * 2. find the value of key from formData.getValue
      * 3. match extracted value form.getvalue with step 1
      * if matched return others no return
      * */
      // var visibilityState = formData.getValue(key: params.visibleWhen ?? 'defaultEnabled');
      // switch(visibilityState.runtimeType){
      //   case bool:
      //     if(visibilityState == false) return Padding(
      //         padding:EdgeInsets.only(
      //           left: style?.padding?.left ?? 0,
      //           top: style?.padding?.top ?? 0,
      //           right: style?.padding?.right ?? 0,
      //           bottom: style?.padding?.bottom ?? 0,
      //         ),
      //         child:SizedBox(height: 64),
      //     );
      //   break;
      // }
    }

    //button disable flag
    bool isDisableButton = false;
    bool isTextFieldDisable = true;


    //debugPrint('isErrorOnDataPress is up $isErrorOnDataPress');

    if (params != null && params.disabledWhen != null) {
      var idFromJson = params.disabledWhen!.split(':').first;
      var currentValue = formData.getValue(key: idFromJson);
      debugPrint('currentValue $currentValue');

      if (params.disabledWhen!.split(':').last == 'value_from_native') {
        isTextFieldDisable = false;
        if(id=='referralCode')
        if (ConfigSingleTon.instance.configData?.rneUrl == null) {
          isTextFieldDisable = false;
        } else {
          if (ConfigSingleTon.instance.configData?.rneUrl != null) {
            var str = ConfigSingleTon.instance.configData?.rneUrl.split("::").first.split('=').last.trim();
              isTextFieldDisable = str!.isNotEmpty;
            debugPrint('isTextFieldDisable $id------->'+isTextFieldDisable.toString());
          }
        }

        if(id=='mobile')
          if (ConfigSingleTon.instance.configData?.mobileNumber == null) {
          isTextFieldDisable = false;
        } else {
          if (ConfigSingleTon.instance.configData?.mobileNumber != null) {
            var str = ConfigSingleTon.instance.configData?.mobileNumber.trim();
              isTextFieldDisable = str!.isNotEmpty;
            debugPrint('isTextFieldDisable $id------->'+isTextFieldDisable.toString());
          }
        }

      }else if(params.disabledWhen!.split(':').last == 'disableByDefault'){

        debugPrint('isDisable $id------->$currentValue');

        if(currentValue!=null){
          isDisableButton = (currentValue.toString() == 'false' ) ? true : false;
        }else{
          isDisableButton = true;
        }

        if(id=='mobile'){
          isTextFieldDisable= (formData.getValue(key: "mobile_check") == 'false' )?false:true;
        }else{
          isTextFieldDisable = true;
        }

      } else {
        isTextFieldDisable =
        (currentValue != null && currentValue
            .toString()
            .length > 0)
            ? false
            : true;
        isDisableButton = (currentValue.toString() == 'false' ) ? true : false;
        if(idFromJson.contains('signature')){
          var signPad = formData.getValue(key: 'signature_pad');
          if (signPad == null || signPad == "false") {
            if(formData.getValue(key: "signatureImageUrl") != null && formData.getValue(key: "signatureImageUrl").toString().isNotEmpty ){
              isDisableButton = (currentValue.toString() == 'false' ) ? true : false ;  // checking for the PEP check box
            }else {
              isDisableButton = true;
            }
          }else{
            isDisableButton = (currentValue.toString() == 'false' ) ? true : false ;  // checking for the PEP check box
          }
        }
      }
    }

    String title = params?.title ?? '';
    String placeholder = params?.placeholder ?? '';
    bool isPartTitle = params?.isPartTitleNeedTobeShown ?? false;
    String subTitle = params?.subTitle ?? '';
    List<Map<String, dynamic>> dynamicList = params?.dynamicList ?? [];
    List<Map<String, dynamic>> defaultList = params?.defaultList ?? [];
    String clickableText = params?.clickableText ?? '';

    String idvalue = '';
    String subIDval = '';
    if (action?.queryParameters != null) {
      idvalue = action?.queryParameters![ID] ?? '';
      subIDval = action?.queryParameters![SUB_ID] ?? '';

      //debugPrint('dynamicList is before $dynamicList');
      if (formData.getValue(key: idvalue) != null) {
        List<Map<String, dynamic>> dataList = formData.getValue(key: idvalue);
        if (dataList.length > 0) {
          dynamicList = dataList;
          //debugPrint('dynamicList is $dynamicList');
        }
      }
    }

    if (validation != null) {
      if (validation.containsKey("compareValue") &&
          formData.getValue(key: validation["compareValue"]["comapre_with"]) !=
              null) {
        String id =
            formData.getValue(key: validation["compareValue"]["comapre_with"]);
        validation["compareValue"]["value"] = id;
        //debugPrint('validation -> $validation');
      }
    }

    Map<String, Widget> widgetRepo = {
      'TextField': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: InputField(
          focusnode: PersistedFormController.getFocusNode(id),
          charLimit: params?.charLimit ?? 40,
          isLetterInCAP: params?.isLetterInCAP ?? false,
          defaultText: params?.stringValue,
          prefixText: params?.left?.first.value,
          title: title,
          readOnly: (params?.disabledWhen != null)
              ? isTextFieldDisable
              : params?.readOnly ?? false,
          isSecure: params?.isMask ?? false,
          hint: placeholder,
          autoPickedKey: params?.autoFetchKey,
          isTextInputRestrictionBasedOnRegex:
          params?.isTextInputRestrictionBasedOnRegex ?? '',
          keyboardType: getKeyboardType(params?.keyboardType ?? 'text'),
          controller: PersistedFormController.getTextEditingController(id),
          isAutoPickedShown: params?.autoFetchKey != null ? (
              (formData.getValue(key: (params?.autoFetchKey == 'email') ? 'AutoPickedEmailHardCodeKey' : 'AutoPickedPhoneHardCodeKey' ) == 'true')
                  ? true
                  : false
          ) : false,
          onAutoPicked: (value) {
            formData.setValue(key: id, value: value);
          },
          autoPickedShown: (value) {
            var key_val = 'AutoPickedPhoneHardCodeKey';
            if(params?.autoFetchKey != null){
              if(params?.autoFetchKey == 'phone'){
                key_val = 'AutoPickedPhoneHardCodeKey';
              }else if(params?.autoFetchKey == 'email'){
                key_val = 'AutoPickedEmailHardCodeKey';
              }
            }
            formData.setValue(key: key_val, value: value.toString());
          },
          onErrorMessageCallBack: (value) {
            isErrorOnDataPress = value;
            debugPrint('isErrorOnDataPress is $isErrorOnDataPress');
          },
          onChange: (value) {
            isErrorOnDataPress = '';
            debugPrint('isErrorOnDataPress onChange is $isErrorOnDataPress');
            if (validation != null) {
              if (validation.containsKey("compareValue")) {
                formData.setValue(key: id, value: value.trim());
              } else {
                formData.setValueWithoutNotifi(key: id, value: value.trim());
              }
            } else {
              formData.setValueWithoutNotifi(key: id, value: value.trim());
            }
          },
          suffixText: params?.right?.first.value,
          validationRule: validation,
          onSufixButtonChange: () {
            // FocusManager.instance.primaryFocus?.unfocus();
            debugPrint("suffix pressed textfield for id -> $id");
            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXT,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
          },
          onTap: () {
            debugPrint(
                'analyticID in textfield widget repo is onTap $analyticID and $id');

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXTFIELD,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
            if (layout.onTap != null) {
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: layout.onTap!,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            }
          },
        ),
      ),
      'TextInputOverLayList': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Container(
          child: TextFieldOverLayWidget(
            controller: PersistedFormController.getTextEditingController(id),
            title: title,
            options: dynamicList,
            defaultList: defaultList,
            isShowPartTitle: isPartTitle,
            validationRule: validation,
            isOverLayShouldbeShownAbove:
                params?.isOverLayShouldbeShownAbove ?? false,
            isLetterInCAP: params?.isLetterInCAP ?? false,
            onTap: () {
              //debugPrint('called ontap');
              debugPrint(
                  'analyticID in TextFieldOverLayWidget widget repo is $analyticID and $id');

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: TEXTFIELD,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );

              if (params?.onTapRequestNeedToBeSend == true) {
                String value = formData.getValue(key: id);
                if (value.isEmpty) {
                  WidgetRepo._debounce(
                    () {
                      WidgetActionHandler.handleAction(
                          context: context,
                          screenId: currentScreen,
                          action: action,
                          id: id,
                          analyticID: analyticID,
                          analytic_metaData: '');
                    },
                  );
                }
              }
            },
            isTextInputRestrictionBasedOnRegex:
                params?.isTextInputRestrictionBasedOnRegex ?? '',
            charLimit: params?.charLimit ?? 250,
            onFieldSubmit: (value) {
              debugPrint('on field value is $value and $id, $idvalue');
              List<Map<String, dynamic>> tempList = [];
              formData.setValueWithoutNotifi(key: idvalue, value: tempList);
            },
            onChanged: (String value) {
              debugPrint(
                  'on change value is $value and $id, $idvalue and $analyticID');
              debugPrint('action.others -> ${action!.others}');

              formData.setValueWithoutNotifi(key: id, value: value);

              if (value.isNotEmpty) {
                if (action.others != null) {
                  List others = action.others!.split(":");
                  //debugPrint('othersssss $others');
                  if (others.first != ONCLEAR) {
                    action.type = others.last;
                  }
                }
                WidgetRepo._debounce(() {
                  WidgetActionHandler.handleAction(
                      context: context,
                      screenId: currentScreen,
                      action: action,
                      analyticID: analyticID,
                      analytic_metaData: analytic_metaData);
                });
              } else {
                WidgetRepo._debounce(() {
                  WidgetActionHandler.handleAction(
                      context: context,
                      screenId: currentScreen,
                      action: action,
                      analyticID: analyticID,
                      analytic_metaData: analytic_metaData);
                });
              }
            },
            onPressed: (value) {
              formData.setValue(key: id, value: value);

              //debugPrint('id pressed is $id and $value and $subIDval');
              List val = value.split('-');
              //debugPrint('valval is $val and ${val.length}');

              if (action!.others != null) {
                List others = action.others!.split(":");
                debugPrint('othersssss on pressed $others');
                if (others.first.toString() == ONCLEAR) {
                  if (id == others[1]) {
                    PersistedFormController.getTextEditingController(others[2])
                        .text = '';
                    Provider.of<FormData>(context, listen: false)
                        .setValue(key: others[2], value: '');
                    List<Map<String, dynamic>> tempList = [];
                    Provider.of<FormData>(context, listen: false)
                        .setValue(key: others[3], value: tempList);
                  }
                }
              }
              Map<String, dynamic> metadata = {};

              if (val.length > 1) {
                formData.setValue(key: id, value: val.last.toString().trim());
                //debugPrint('idddd is $id and ${val.last.toString().trim()}');
                if (analytic_metaData.length > 0) {
                  List data = analytic_metaData.split(",");
                  debugPrint('data if cause is $data and ${data.length}');
                  List subdata = data.length > 1
                      ? data.first.toString().split(":")
                      : data.last.toString().split(":");

                  debugPrint('subdata if cause is $subdata');

                  if (id == subdata.last.toString()) {
                    metadata[subdata.first.toString()] =
                        val.last.toString().trim();
                  } else {
                    metadata[subdata.first.toString()] =
                        val.last.toString().trim();
                  }
                } else {
                  List keydata = subIDval.split(':');
                  if (id == keydata.first.toString()) {
                    metadata['branch name'] = val.first.toString().trim();
                  }
                }
              } else {
                formData.setValue(key: id, value: value);
                //debugPrint('elese called $id and $value');
                if (analytic_metaData.length > 0) {
                  List data = analytic_metaData.split(",");
                  List subdata = data.first.toString().split(":");
                  metadata[subdata.first.toString()] = value;
                } else {
                  //done it for analytic purpose
                  String key = 'branch name';
                  if (id == 'bank_name_main') {
                    key = 'bank name';
                  }
                  metadata[key] = value;
                }
              }

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: TEXTFIELD,
                id: id,
                metaData: metadata,
                flowvalue: formData.getValue(key: 'flow'),
              );

              if (subIDval.length > 0) {
                List key = subIDval.split(":");
                List val = value.split('-');

                formData.setValue(key: key.first, value: val.first);
                formData.setValue(
                    key: key.last, value: val.last.toString().trim());
                StartupUtils.preFillForm(
                    context: context,
                    key: key.last,
                    value: val.last.toString().trim());

                Navigator.pop(context);
              }
            },
            readonly: (params?.disabledWhen != null)
                ? isTextFieldDisable
                : params?.readOnly ?? false,
            suffixText: params?.right?.first.value,
            onSufixButtonChange: () {
              debugPrint("onSufixButtonChange pressed textfield for id -> $id");
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: TEXT,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
              if (action!.others != null) {
                List others = action.others!.split(":");
                //debugPrint('othersssss $others');
                if (others.first.toString() != ONCLEAR) {
                  action.type = others[((others.length - 1) / 2).toInt()];
                }
                //debugPrint('othersssss ${action.type}');
              }

              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            },
          ),
        ),
      ),
      'DateInputField': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: CustomDateField(
          preFillDate: formData.getValue(key: id) ?? '',
          onTapCallBack: () {
            debugPrint('called ontap date');
            debugPrint('called ontap date $analyticID and $id');

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXTFIELD,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );

          },
        onParticularTapCallBack:(value){

            String eventid = '73.0.0.60.59';
            String eventname = 'MM';
            if(value.toLowerCase() == 'dd'){
               eventid = '73.0.0.60.60';
               eventname = 'DD';

            }
            else if(value.toLowerCase() == 'yyyy'){
              eventid = '73.0.0.60.61';
              eventname = 'YYYY';
            }

      AnalyticHelper.logClickEvent(
        analyticID: P_DOBCALENDAR,
        component: USERINPUTFIELD,
        id: id,
        eventid: eventid,
        eventname: eventname,
        metaData: {},
        flowvalue: formData.getValue(key: 'flow'),
      );
    },
          currentValue: (dateValue) {
            print('dateValue  --> dateValue: $dateValue');
            if ('/'.allMatches(dateValue).length == 2 &&
                dateValue.length == 10) {
              var date = DateTime.now();
              var birthDate = DateFormat('dd/MM/yyyy').parse(dateValue);
              var firstDate = DateTime(date.year - 108, date.month, date.day);
              var lastDate = DateTime(date.year - 18, date.month, date.day);
              if (firstDate.isBefore(birthDate) &&
                  lastDate.isAfter(birthDate)) {
                print('-----------> allowed date for datePicker $id ');

                AnalyticHelper.logClickEvent(
                  analyticID: P_DOBCALENDAR,
                  component: BUTTON,
                  id: id,
                  metaData: {},
                  flowvalue: formData.getValue(key: 'flow'),
                );

                formData.setValueWithoutNotifi(key: id, value: dateValue);
                PersistedFormController.getTextEditingController(id).text =
                    dateValue;
              }
            }
          },
          rightIconSvg: params?.clickableText,
          onPressRightIcon: () {
            debugPrint('data called!!! now $analyticID and $id ${formData.getValue(key: 'flow')}');
            // button click event
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: ICON,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );

            // impression event
            AnalyticHelper.logImpressionEvent(
                screenname: P_DOBCALENDAR ,type:POPUP, idvalue: id);

            WidgetActionHandler.datePicker(context, formData, id, 'dd/MM/yyyy');
          },
          errorCallback: (msg, type) {
            print('errorCallback  --> msg: $msg and type: $type');
            // disable the button and will show the error message if type is false
            formData.setValueWithoutNotifi(key: 'dateError', value: type);
            formData.setValue(key: 'dateErrorMsg', value: msg);
          },),
      ),
      'DatePickerTextField': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Container(
          child: InputField(
            isTextInputRestrictionBasedOnRegex:
            params?.isTextInputRestrictionBasedOnRegex ?? '',
              charLimit: params?.charLimit ?? 40,
              rightIconSvg: (params?.readOnly ?? false)?"":params?.clickableText,
              onPressRightIcon: ()=>{
              debugPrint("onPressRightIcon ------------------> pressed"),
              if (!(params?.readOnly?? false) )WidgetActionHandler.datePicker(context, formData, id,params?.subTitle??'dd/MM/yyyy'),
              },
            onTap: () {
              debugPrint(
                  "onPressed DatePickerTextField called $id and $analyticID");
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: TEXTFIELD,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
              if (params?.readOnly ?? false) return;
            },
            defaultText: params?.stringValue,
            prefixText: params?.left?.first.value,
            title: title,
            readOnly: params?.readOnly ?? false,
            isSecure: params?.isMask ?? false,
            hint: placeholder,
            keyboardType: getKeyboardType(params?.keyboardType ?? 'text'),
            controller: PersistedFormController.getTextEditingController(id),
            onChange: (value) {
              formData.setValueWithoutNotifi(key: id, value: value);
            },
            suffixText: params?.right?.first.value,
            validationRule: validation,
            onSufixButtonChange: () {
              debugPrint("suffix pressed");
            },
          ),
        ),
      ),
      'OTPField': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: OTPWidget(
          title: title,
          resendTitle: 'RESEND OTP',
          onComplete: (otp) {
            formData.setValue(key: id, value: otp);
            return Null;
          },
          onResend: () {
            debugPrint("==OTP Resent==");
            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);
          },
        ),
      ),
      'CheckBoxField': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: CheckboxTitle(
          title: title,
          isChecked: ( formData.getValue(key: id) == null || formData.getValue(key: id) == 'true' )
              ? true
              : false,
          onChecked: (value) {
            formData.clearFlagValueWithoutNotify(':loading');
            formData.setValue(key: id, value: value.toString());
            debugPrint(
                '===============$value============== id and analytic id $id and $analyticID');
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: CHECKBOX,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
          },
        ),
      ),
      'ClickableText': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: ClickableText(
          nonClickableTextOne: title, //'By entering OTP you agree with our ' ,
          clickableTextOne: clickableText, //'Terms & Conditions',
          firstTextCallback: () {
            FocusManager.instance.primaryFocus?.unfocus();
            debugPrint(
                'ClickableText id is $id and $analyticID and $analytic_metaData');
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXT,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);
          },
        ),
      ),
      'Button': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: CustomButton(
            title: title,
            bgColor: (((params?.bgColorName ?? "") == "black")
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColor),
            textColor: ((params?.textColorName ?? "") == "black")
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).scaffoldBackgroundColor,
            leftIcon: params?.placeholder,
            isOutLine: params?.isOutLine ?? false,
            onPressed: () {
              debugPrint(
                  "onPressed called widgetRepo : " + (action?.api ?? ''));
              FocusManager.instance.primaryFocus?.unfocus();
              if (params?.native_analytic_event_label != null){
                var refCode = formData.getValue(key: params?.native_analytic_event_label ?? '');
                NativeAnalyticsHelper.shared.logEventWith(params?.native_analytic_types,params?.native_analytic_event_name, params?.native_analytic_event_action, context, eventLabel: (refCode != null && refCode != '') ? refCode.toString() : 'NA');
              }else {
                NativeAnalyticsHelper.shared.logEventWith(params?.native_analytic_types,
                    params?.native_analytic_event_name, params?.native_analytic_event_action, context);
              }
              // Check Form Validation
              if (id == "ESign-TryAgain-Button") {
                formData.setValue(key: "ESign", value: "true");
              } else if (PersistedFormController.getFormKeys(screenIndex)
                          .currentState !=
                      null &&
                  PersistedFormController.getFormKeys(screenIndex)
                      .currentState!
                      .validate()) {
                debugPrint("===== VALIDATED FORM $currentScreen  ====");
                isErrorOnDataPress = '';
                Map<String, dynamic> metadata = {};
                if (analytic_metaData.length > 0) {
                  List maindata = analytic_metaData.split(',');

                  if (maindata.last.contains('button')) {
                    maindata = maindata.sublist(0, maindata.length - 1);
                  }

                  //debugPrint('maindata  is $maindata');
                  bool isDataset = false;

                  maindata.forEach(
                    (element) {
                      debugPrint('element is $element');
                      List subdata = element.toString().split(":");
                      debugPrint('subdata is $subdata');

                      if(subdata.first.toString() ==  'no_id'){
                          if(isDataset == false){
                             metadata['Slot'] = subdata.last.toString();
                        }
                      }
                      else{
                        if(analyticID == 's-annualincome'){
                          //debugPrint('add is ${formData.getValue(key:'income_analytic')}');
                          if(formData.getValue(key:'income_analytic') == null){
                            if(subdata.first.toString() == 'value'){
                              metadata['annual income'] = subdata.last.toString();
                            }
                          }
                          else{
                            if(subdata.first.toString() != 'value'){
                              metadata[subdata.first.toString()] = formData.getValue(key: subdata.last.toString()+'_analytic');
                            }
                          }
                        }
                        else{
                          metadata[subdata.first.toString()] =
                              formData.getValue(key: subdata.last.toString()) ?? '';
                          //debugPrint('formData.getValue(key: subdata.last.toString()) is ${formData.getValue(key: subdata.last.toString())}');
                          isDataset =
                          (formData.getValue(key: subdata.last.toString()) == null) ||
                              (formData.getValue(key: subdata.last.toString()).toString().isEmpty) ? false : true;
                        }
                      }

                    },
                  );
                }

                //debugPrint('data is $metadata and id $id and ${action?.type} and $analyticID $analytic_metaData');
                //debugPrint('analytic_metaData is $metadata');

                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );
                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: action,
                    id: id,
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              } else if (PersistedFormController.getFormKeys(screenIndex)
                      .currentState ==
                  null) {
                Map<String, dynamic> metadata = {};
                isErrorOnDataPress = '';
                debugPrint(
                    'data in else is $metadata and id $id and ${action?.type} and $analyticID $analytic_metaData');

                if (analytic_metaData.length > 0) {
                  List maindata = analytic_metaData.split(',');
                  debugPrint('analytic_metaData in else is $metadata');
                  if (maindata.last.contains('button')) {
                    maindata = maindata.sublist(0, maindata.length - 1);
                  }
                  maindata.forEach((element) {
                    List subdata = element.toString().split(":");
                    metadata[subdata.first.toString()] =
                        formData.getValue(key: subdata.last.toString()) ?? '';
                  });
                }
                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );

                debugPrint("metadata is in else case $metadata");

                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: action,
                    id: id,
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              } else
                debugPrint("===== THIS FORM $currentScreen IS NOT VALUD ==== $isErrorOnDataPress");

              if(isErrorOnDataPress.length > 0){
                debugPrint('value error id $id and $analyticID and $analytic_metaData');

                Map<String, dynamic> metadata = {};
                metadata['message'] = isErrorOnDataPress;
                metadata['errorType'] = 'Frontend';

                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );

              }

            },
            isLoadType: params?.isLoaderType ?? false,
            isLoading: (formData.getValue(key: id + ':loading') == 'false' ||
                    formData.getValue(key: id + ':loading') == null)
                ? false
                : true,
            isDisable: isDisableButton,
          )),
      'SlotButton': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: SlotButton(
            slotText: formData.getValue(key: id) ?? title,
            slotConfirmText: subTitle,
            textColor: Theme.of(context).primaryColorLight,
            leftIcon: params?.placeholder,
            rightIcon: params?.clickableText,
            isOutLine: params?.isOutLine ?? false,
            isSlotBooked: formData.getValue(key: id) != null,
            onPressed: () {
              debugPrint(
                  "onPressed called widgetRepo : " + (action?.api ?? ''));
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            },
          )),
      'SlotPicker': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: SlotPickerList(
              title: title,
              dayList: params?.options ?? [],
              valueList: dynamicList,
              onSelect: (title, value, day) => {
                    debugPrint(
                        "Selected CHECKBOX value is : " + title.toString()),
                    Future.delayed(Duration(milliseconds: 500), () {
                      AnalyticHelper.logClickEvent(
                        analyticID: analyticID,
                        component: SELECT,
                        id: id,
                        metaData: {"message": "${title.toString()}"},
                        flowvalue: formData.getValue(key: 'flow'),
                      );

                      formData.setValue(key: id, value: '$day $title');
                      formData.setValue(key: id + '_day', value: day);
                      formData.setValue(key: id + '_value', value: value);
                      NavigationUtils.pop(context: context);
                    })
                  })),
      'TextButton': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: CustomTextButton(
            title: title,
            leftIcon: params?.placeholder,
            onPressed: () {
              debugPrint('data is and id $id and $analyticID');
              NativeAnalyticsHelper.shared.logEventWith(params?.native_analytic_types,
                  params?.native_analytic_event_name, params?.native_analytic_event_action, context);
              if (action?.analytic_id == null) {
                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: TEXT,
                  id: id,
                  metaData: {},
                  flowvalue: formData.getValue(key: 'flow'),
                );
              } else {
                if (action?.analytic_id != 'no_log') {
                  AnalyticHelper.logClickEvent(
                    analyticID: analyticID,
                    component: TEXT,
                    id: id,
                    metaData: {},
                    flowvalue: formData.getValue(key: 'flow'),
                  );
                }
              }

              FocusManager.instance.primaryFocus?.unfocus();
              debugPrint(
                  "custom button onPressed called" + (action?.api ?? ''));
              if (id == "signature_pad") {
                if (signatureKey.currentState != null) {
                  signatureKey.currentState!.clear();
                }
                formData.clearFlagValueWithoutNotify(':loading');  // remove the loader if loading
                formData.setValueWithoutNotifi(key: "signatureImageUrl", value: null);
                formData.setValue(key: id, value: "${false}");
              }
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  id: id,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            },
          )),
      'ProgressHeader': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child:
            ProgressHeader(title: title, progress: params?.doubleValue ?? 0.3),
      ),
      'Label': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Label(
            title: title,
            isAlignCenter: params?.isAlignCenter ?? false,
            textStyle: ThemeHelper.getTextTheme(context, params?.themeStyle)),
      ),
      'ErrorLabel': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: (Provider.of<FormData>(context).getValue(key: id) != null)
            ? Visibility(
                visible:
                    Provider.of<FormData>(context).getValue(key: id) == 'false',
                child: Label(
                  fontSize: params?.doubleValue,
                  title: (id == 'dateError') ? (formData.getValue(key: 'dateErrorMsg')) : title,
                  isAlignCenter: params?.isAlignCenter ?? false,
                  textStyle: TextStyle(
                      fontSize: params?.doubleValue,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Barlow',
                      color: Theme.of(context).errorColor),
                ))
            : Padding(padding: EdgeInsets.zero),
      ),
      'Icon': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: CustomIcon(name: title),
      ),
      'Image': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: CustomImage(
              name: title,
              size: params?.doubleValue != null
                  ? Size(params?.doubleValue ?? 0.0, params?.doubleValue ?? 0.0)
                  : null)),
      'UPIImage': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: CustomImage(
              name: WidgetActionHandler.getBankIcon(bankName: formData.getValue(key: id)??'.svg'),
              size: params?.doubleValue != null
                  ? Size(params?.doubleValue ?? 0.0, params?.doubleValue ?? 0.0)
                  : null)),
      'UPIBankLabel': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Label(
            title: Provider.of<FormData>(context, listen: false)
                .getValue(key: id)??'',
            isAlignCenter: params?.isAlignCenter ?? false,
            textStyle: ThemeHelper.getTextTheme(context, params?.themeStyle)),
      ),

      'RadioButton': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: isDualSim?Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Radio(
              value: "sim1",
              groupValue: formData.getValue(key: 'upi_sim')??'sim1',
              onChanged: (v){
                formData.setValue(key: "upi_sim", value: v);
                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: RADIO_BUTTON,
                  id: id,
                  metaData: {"action":v},
                  flowvalue: formData.getValue(key: 'flow'),
                );
              },
            ),
            new Text(
              'Sim 1',
              style: new TextStyle(fontSize: 16.0),
            ),
            new Radio(
              value: "sim2",
              groupValue: formData.getValue(key: 'upi_sim')??'0',
              onChanged: (v){
                formData.setValue(key: "upi_sim", value: v);
                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: RADIO_BUTTON,
                  id: id,
                  metaData: {"action":v},
                  flowvalue: formData.getValue(key: 'flow'),
                );
              },
            ),
            new Text(
              'Sim 2',
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ):Container(),
      ),

      'CameraComponent': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: CustomCamera(
            cameraLensDirection: CameraLensDirection.back,
            width: 330,
            height: 200,
            buttonPadding: 100,
            onCLick: (value) {
              debugPrint(
                  'camera componet is $analyticID and $id and $analytic_metaData');

              debugPrint(
                  "CustomCamera button action?.api --->" + (action?.api ?? ''));
              debugPrint("CustomCamera button action?.postNavigate --->" +
                  (action?.postNavigate ?? ''));
              Provider.of<FormData>(context, listen: false)
                  .setValue(key: action?.api ?? '', value: value);

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );

              if(id == 'aadhaarFrontLocal' || id == 'aadhaarBackLocal'){
                NavigationUtils.pop(context: context);
                if(formData.getValue(key:'aadhaarBackLocal' ) != null &&
                    formData.getValue(key:'aadhaarBackLocal' ).toString().isNotEmpty && id == 'aadhaarFrontLocal'){
                  NavigationUtils.pushNamed(
                      context: context, route: '/aadhar_back');
                  NavigationUtils.pushNamed(
                      context: context, route: '/aadhar_preview');
                }else{
                  NavigationUtils.pushNamed(
                      context: context, route: action?.postNavigate ?? '');
                }
              }else{
                NavigationUtils.pushNamed(
                    context: context, route: action?.postNavigate ?? '');
              }
            }),
      ),
      'CapturedImage': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: (Provider.of<FormData>(context).getValue(key: id) != null)
            ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CapturedImage(
                  bgColor: params?.textColorName=='red'?Colors.red:null,
                  imagePath: Provider.of<FormData>(context).getValue(key: id),
                  height: params?.doubleValue ?? 220,
                  iconhorizontalPadding: 8,
                  iconText: params?.title ?? "",
                  onPress: () {
                    debugPrint(
                        'round button analyticID $analyticID and id $id');
                    AnalyticHelper.logClickEvent(
                      analyticID: analyticID,
                      component: CARD,
                      id: id,
                      metaData: {},
                      flowvalue: formData.getValue(key: 'flow'),
                    );
                    WidgetActionHandler.handleAction(
                        context: context,
                        screenId: currentScreen,
                        action: action,
                        analyticID: analyticID,
                        analytic_metaData: analytic_metaData);
                  },
                ),
              )
            : Text('No image selected'),
      ),
      'LoadSignature': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: (Provider.of<FormData>(context).getValue(key: id) != null)
            ? DottedBorder(
                strokeWidth: 1.0,
                borderType: BorderType.RRect,
                color: Theme.of(context).primaryColorDark,
                radius: Radius.circular(8.0),
                dashPattern: [6, 3],
                padding: EdgeInsets.all(8.0),
                child: CapturedImage(
                  imagePath: Provider.of<FormData>(context).getValue(key: id),
                  height: params?.doubleValue ?? 220,
                  iconhorizontalPadding: 8,
                  iconText: "",
                  onPress: () => {
                    WidgetActionHandler.handleAction(
                        context: context,
                        screenId: currentScreen,
                        action: action)
                  },
                ))
            : Container(),
      ),
      'CapturedSelfieImage': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: (Provider.of<FormData>(context).getValue(key: id) != null)
            ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CapturedImage(
                  imagePath: Provider.of<FormData>(context).getValue(key: id),
                  height: 350,
                  iconhorizontalPadding: 8,
                  iconText: "",
                  onPress: () => {
                    WidgetActionHandler.handleAction(
                        context: context,
                        screenId: currentScreen,
                        action: action,
                        analyticID: analyticID,
                        analytic_metaData: analytic_metaData)
                  },
                ),
              )
            : Text('No image selected'),
      ),
      'CapturedSign': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: (Provider.of<FormData>(context).getValue(key: id) != null)
            ? DottedBorder(
                strokeWidth: 1.0,
                borderType: BorderType.RRect,
                color: Theme.of(context).primaryColorDark,
                radius: Radius.circular(8.0),
                dashPattern: [6, 3],
                padding: EdgeInsets.all(8.0),
                child: CapturedImage(
                  imagePath: Provider.of<FormData>(context).getValue(key: id),
                  height: 334.0,
                  iconhorizontalPadding: 8,
                  iconText: "",
                  onPress: () => {
                    WidgetActionHandler.handleAction(
                        context: context,
                        screenId: currentScreen,
                        action: action)
                  },
                ))
            : Text('No image selected'),
      ),
      'RoundButton': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: RoundButton(
            radius: 64.0,
            outerPadding: 4.0,
            onPressed: () {
              debugPrint('round button analyticID $analyticID and id $id');
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: ROUND_BUTTON,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
              FocusManager.instance.primaryFocus?.unfocus();
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            },
          )),
      'SelectPersonalOptions': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: SelectPersnalOption(
            options: dynamicList,
            value: formData.getValue(key: id),
            onPressed: (value) {
              FocusManager.instance.primaryFocus?.unfocus();
              debugPrint(
                  "SelectPersonalOption pressed id and analytic id : $id and $analyticID" +
                      value.toString());
              formData.setValue(key: id, value: value);

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: SELECT,
                id: id,
                metaData: (id == 'gender')
                    ? {"gender": value.toString()}
                    : {"maritalStatus": value.toString()},
                flowvalue: formData.getValue(key: 'flow'),
              );

              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            },
          )),
      'SelectOptions': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: SelectOption(
          options: dynamicList,
          value: formData.getValue(key: id),
          onPressed: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
            debugPrint("SelectOption pressed : $id" + value.toString());
            formData.setValue(key: id, value: value);

            if (id == "FnOOptions" && value == "No") {
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: value,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
              WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: WidgetAction(
                    api: "/v1/kyc/skip/bank/statement",
                    type: "navigateWithAPI",
                    method: "POST",
                    analytic_id: analyticID,
                    analytic_event_metadata: analytic_metaData),
              );
            } else if (id == "FnOOptions" && value == "Yes") {
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: value,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            } else if (id == "AadhaarOptions" && value == "Yes") {
              debugPrint('round button analyticID $analyticID and id $id');
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: value,
                metaData: {
                  "message": "is your aadhar linked to your mobile  $value"
                },
                flowvalue: formData.getValue(key: 'flow'),
              );
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action:
                      WidgetAction(api: "/digilocker", type: "navigateToRoute"),
                  analyticID: analyticID);
            } else if (id == "AadhaarOptions" && value == "No") {
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: value,
                metaData: {
                  "message": "is your aadhar linked to your mobile  $value"
                },
                flowvalue: formData.getValue(key: 'flow'),
              );
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: WidgetAction(
                      api: "/aadhaar_main", type: "navigateToRoute"),
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            } else if (id == 'occupation') {
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: SELECT,
                id: id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );
            } else if (id == "income") {
              //debugPrint('dynamicList $dynamicList');

              int index = 0;
              int updatedindex = 0;
              dynamicList.forEach((element) {
                 if(element.values.contains(value.toString())){
                    //debugPrint('index is $index');
                    updatedindex = index;
                 }
                 index++;
               });

              Map value_map = dynamicList[updatedindex];
              String val = value_map['title'].toString().replaceAll("\u{20B9}","");
              formData.setValueWithoutNotifi(key: id+'_analytic', value: val);

              //debugPrint('add is ${formData.getValue(key: id+'_analytic')}');

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: SELECT,
                id: id,
                metaData: {"annual income": val},
                flowvalue: formData.getValue(key: 'flow'),
              );
            } else if (id == "BankOptions") {
              formData.setValueWithoutNotifi(key: "BankValue", value: value);
              otherBank.forEach((element) {
                if(element['bank_name'].toString()==value)
                formData.setValueWithoutNotifi(key: "bankcode", value: element['bank_code'].toString());
              });

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: BUTTON,
                id: value.toString().toLowerCase(),
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );

              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: action,
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData);
            }
          },
        ),
      ),

      'Dropdown': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Dropdown(
          options: otherBank,
          placeholder: params?.title,
          onPressed: (val) {

            formData.setValue(key: "BankValue", value: val['bank_name']);
            formData.setValue(key: "bankcode", value: val['bank_code']);

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: DROPDOWN,
              id: id,
              metaData: {"selected bank":val['bank_name'] ?? ''},
              flowvalue: formData.getValue(key: 'flow'),
            );

            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);


            formData.setValue(key: "BankOptions", value: "");

          },
        ),
      ),

      'DropDownWithSearchBar': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: DropDownWithSearchBarWidget(
          options: otherBank,
          title: params?.title ?? '',
          searchTitle: params?.subTitle ?? '',
          defaultIcon: params?.placeholder ?? '',
          controller: PersistedFormController.getTextEditingController(id),
          onTapSearchTextfield: (){
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXTFIELD,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
          },
          onPressed: (val) {
            formData.setValue(key: "BankValue", value: val['bank_name']);
            formData.setValue(key: "bankcode", value: val['bank_code']);

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: DROPDOWN,
              id: id,
              metaData: {"selected bank":val['bank_name']},
              flowvalue: formData.getValue(key: 'flow'),
            );

            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);

            formData.setValue(key: "BankOptions", value: "");

          },
        ),
      ),

      'HorizontalOptions': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: HorizontalOption(
            currentScreen: params?.uploadFlow ?? '',
            options: WidgetRepo.documentsData ?? [],
            value: formData.getValue(key: id),
            onPressed: (value) {
              debugPrint("HorizontalOption pressed : " + value.toString());
              // formData.setValue(key: id, value: value);
              // if(formData.getValue(key: 'flow') != value.toString()) {
              //   WidgetActionHandler.handleAction(context: context,
              //       screenId: currentScreen,
              //       action: WidgetAction(
              //           api: "/${value.toString()}", type: action!.type));
              // }
            },
          )),
      'SelectOptionCard': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: SelectOptionCard(
          options: dynamicList,
          value: formData.getValue(key: id),
          onPressed: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
            debugPrint(
                "round button pressed : " + value.toString() + id.toString());
            formData.setValue(key: id, value: value);

            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: SELECT,
              id: id,
              metaData: {"employment type": value.toString()},
              flowvalue: formData.getValue(key: 'flow'),
            );

            // formData.setValue(key: id,value: index.toString());
            // WidgetActionHandler.handleAction(context: context,screenId:currentScreen ,action: action);
          },
        ),
      ),
      'SelectBankOptionCard': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: (Provider.of<FormData>(context).getValue(key: "imps")!=null && Provider.of<FormData>(context).getValue(key: "imps")=="true" )?SelectBankOptionCard(
            options: WidgetActionHandler.getSelectedBankList(formData:formData),
            value: formData.getValue(key: id),
            onPressed: (list) {
              debugPrint(
                  'SelectBankOptionCard123  $list');

              FocusManager.instance.primaryFocus?.unfocus();
              formData.setValueWithoutNotifi(key: "btn_link", value: "true");
              formData.setValueWithoutNotifi(key: "ifsc", value: list["account_ifsc"]??"");
              formData.setValueWithoutNotifi(key: "bankFullName", value: list["account_holder"]??"");
              formData.setValueWithoutNotifi(key: "bankName", value: list["account_bank"]??"");
              formData.setValue(key: "bankAccountNumber", value: list["account_number"]??"");

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: CARD,
                id: id,
                metaData: {"bank_name":list["account_bank"]??"","bank_ifsc":list["account_ifsc"]??""},
                flowvalue: formData.getValue(key: 'flow'),
              );

              // debugPrint("round button pressed : " + value.toString());
              // formData.setValue(key: id, value: value);
              // formData.setValue(key: id,value: index.toString());
              // WidgetActionHandler.handleAction(context: context,screenId:currentScreen ,action: action);
            },
          ):SelectBankOptionCard(
            options: upiUserBankList,
            value: formData.getValue(key: id),
            onPressed: (list) {
              debugPrint(
                  'SelectBankOptionCard  $list');

              FocusManager.instance.primaryFocus?.unfocus();
              formData.setValueWithoutNotifi(key: "btn_link", value: "true");
              formData.setValueWithoutNotifi(key: "ifsc", value: list["account_ifsc"]??"");
              formData.setValueWithoutNotifi(key: "bankFullName", value: list["account_holder"]??"");
              formData.setValueWithoutNotifi(key: "bankName", value: list["account_bank"]??"");
              formData.setValue(key: "bankAccountNumber", value: list["account_number"]??"");

              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: CARD,
                id: id,
                metaData: {"bank_name":list["account_bank"]??"","bank_ifsc":list["account_ifsc"]??""},
                flowvalue: formData.getValue(key: 'flow'),
              );

              // debugPrint("round button pressed : " + value.toString());
              // formData.setValue(key: id, value: value);
              // formData.setValue(key: id,value: index.toString());
              // WidgetActionHandler.handleAction(context: context,screenId:currentScreen ,action: action);
            },
          )),
      'UPIButton': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: CustomButton(
            title: (Provider.of<FormData>(context).getValue(key: "imps")!=null && Provider.of<FormData>(context).getValue(key: "imps")=="true" )?subTitle:title,
            bgColor: (((params?.bgColorName ?? "") == "black")
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColor),
            textColor: ((params?.textColorName ?? "") == "black")
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).scaffoldBackgroundColor,
            leftIcon: params?.placeholder,
            isOutLine: params?.isOutLine ?? false,
            onPressed: () {
              debugPrint(
                  "onPressed called widgetRepo : " + (action?.api ?? ''));
              FocusManager.instance.primaryFocus?.unfocus();
              // Check Form Validation
              if (id == "ESign-TryAgain-Button") {
                formData.setValue(key: "ESign", value: "true");
              } else if (PersistedFormController.getFormKeys(screenIndex)
                  .currentState !=
                  null &&
                  PersistedFormController.getFormKeys(screenIndex)
                      .currentState!
                      .validate()) {
                debugPrint("===== VALIDATED FORM $currentScreen  ====");
                isErrorOnDataPress = '';
                Map<String, dynamic> metadata = {};
                if (analytic_metaData.length > 0) {
                  List maindata = analytic_metaData.split(',');

                  if (maindata.last.contains('button')) {
                    maindata = maindata.sublist(0, maindata.length - 1);
                  }

                  //debugPrint('maindata  is $maindata');
                  bool isDataset = false;

                  maindata.forEach(
                        (element) {
                      debugPrint('element is $element');
                      List subdata = element.toString().split(":");
                      //debugPrint('subdata is $subdata');

                      if(subdata.first.toString() ==  'no_id'){
                        if(isDataset == false){
                          metadata['Slot'] = subdata.last.toString();
                        }
                      }
                      else{
                        if(analyticID == 's-annualincome'){

                          int index = 0;
                          int updatedindex = 0;

                          if(dynamic_list.isNotEmpty){
                            dynamic_list.forEach((element) {
                              if(element.values.contains(formData.getValue(key:maindata.last.toString()))){
                                updatedindex = index;
                              }
                              index++;
                            });
                            Map value_map = dynamic_list[updatedindex];
                            String val = value_map['title'].toString().replaceAll("\u{20B9}","");
                            metadata[subdata.first.toString()] = val;
                          }
                        }
                        else{
                          metadata[subdata.first.toString()] =
                              formData.getValue(key: subdata.last.toString()) ?? '';
                          debugPrint('formData.getValue(key: subdata.last.toString()) is ${formData.getValue(key: subdata.last.toString())}');
                          isDataset =
                          (formData.getValue(key: subdata.last.toString()) == null) ||
                              (formData.getValue(key: subdata.last.toString()).toString().isEmpty) ? false : true;
                        }
                      }

                    },
                  );
                }

                debugPrint(
                    'data is $metadata and id $id and ${action?.type} and $analyticID $analytic_metaData');
                debugPrint('analytic_metaData is $metadata');

                String temp_id = (formData.getValue(key: "imps")!=null && formData.getValue(key: "imps")=="true" ) ? "$id _1" :id;
                temp_id = temp_id.replaceAll(" ", "");

                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: temp_id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );
                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: action,
                    id: id,
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              } else if (PersistedFormController.getFormKeys(screenIndex)
                  .currentState ==
                  null) {
                Map<String, dynamic> metadata = {};
                isErrorOnDataPress = '';
                debugPrint(
                    'data in else is $metadata and id $id and ${action?.type} and $analyticID $analytic_metaData');

                if (analytic_metaData.length > 0) {
                  List maindata = analytic_metaData.split(',');
                  debugPrint('analytic_metaData in else is $metadata');
                  if (maindata.last.contains('button')) {
                    maindata = maindata.sublist(0, maindata.length - 1);
                  }
                  maindata.forEach((element) {
                    List subdata = element.toString().split(":");
                    metadata[subdata.first.toString()] =
                        formData.getValue(key: subdata.last.toString()) ?? '';
                  });
                }
                String temp_id = (formData.getValue(key: "imps")!=null && formData.getValue(key: "imps")=="true" ) ? "$id _1" :id;
                temp_id = temp_id.replaceAll(" ", "");

                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: temp_id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );

                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: action,
                    id: id,
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              } else
                debugPrint("===== THIS FORM $currentScreen IS NOT VALUD ==== $isErrorOnDataPress");

              if(isErrorOnDataPress.length > 0){

                Map<String, dynamic> metadata = {};
                metadata['message'] = isErrorOnDataPress;
                metadata['errorType'] = 'Frontend';
                String temp_id = (formData.getValue(key: "imps")!=null && formData.getValue(key: "imps")=="true" ) ? "$id _1" :id;
                temp_id = temp_id.replaceAll(" ", "");
                AnalyticHelper.logClickEvent(
                  analyticID: analyticID,
                  component: BUTTON,
                  id: temp_id,
                  metaData: metadata,
                  flowvalue: formData.getValue(key: 'flow'),
                );

              }

            },
            isLoadType: params?.isLoaderType ?? false,
            isLoading: (formData.getValue(key: id + ':loading') == 'false' ||
                formData.getValue(key: id + ':loading') == null)
                ? false
                : true,
            isDisable: (Provider.of<FormData>(context).getValue(key: "imps")!=null && Provider.of<FormData>(context).getValue(key: "imps")=="true" )?false:isDisableButton,
          )),
      'UPILabel': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Label(
            title: (Provider.of<FormData>(context).getValue(key: "imps")!=null && Provider.of<FormData>(context).getValue(key: "imps")=="true" )?subTitle:title,
            isAlignCenter: params?.isAlignCenter ?? false,
            textStyle: ThemeHelper.getTextTheme(context, params?.themeStyle)),
      ),
      'NumberedList': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: NumberedList(
          instructions: params?.options ?? [],
        ),
      ),
      "SignaturePad": Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: SignatureBox(
          signatureKey: signatureKey,
          height: 330,
          onSign: () {
            WidgetRepo._debounce(() {
              debugPrint('First');
              formData.setValue(key: id, value: "${true}");
              formData.setValueWithoutNotifi(key: "signature_pad", value: "${true}");
            });
            debugPrint("Signature Done");
            //disable the loader on the CTA button
            formData.clearFlagValueWithoutNotify(':loading');
          },
        ),
      ),
      'GifAnimation':Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: GIFAnaimationWidget(imagename: title,imageoverlayename: subTitle,),
      ),
      'SelectBankAccountOptions': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: SelectBankOptionCard(
            options: dynamicList,
            value: '',
            onPressed: (index) {
              debugPrint("round button pressed");
            },
          )),
      'BlinkingText': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: BlinkingText(textList: params?.options ?? []),
      ),
      'SwipableImages': Padding(
          padding: EdgeInsets.only(
            left: style?.padding?.left ?? 0,
            top: style?.padding?.top ?? 0,
            right: style?.padding?.right ?? 0,
            bottom: style?.padding?.bottom ?? 0,
          ),
          child: (WidgetActionHandler.getImageList(
                      imageResID: params?.options ?? [],
                      formData: Provider.of<FormData>(context))
                  .isNotEmpty)
              ? SwipeableImages(
                  imagePath: WidgetActionHandler.getImageList(
                      imageResID: params?.options ?? [],
                      formData: Provider.of<FormData>(context)),
                  height: 200,
                  imagePadding: 10,
            onPress: (pos) {
              String a_id  = id;
              if(params?.options != null){
                if(params!.options!.isNotEmpty){
                  a_id = params.options![pos];
                }
              }
              AnalyticHelper.logClickEvent(
                analyticID: analyticID,
                component: TEXT,
                id: a_id,
                metaData: {},
                flowvalue: formData.getValue(key: 'flow'),
              );

              if(pos == 1 || currentScreen == 'aadhaarOCRConfirmation'){
                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: WidgetAction(api: 'navigatorPop', type: 'openCallback'),
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              }else{
                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: action,
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData);
              }


            }, ctaHeight: 50,
          )
              : Text('No image selected')),
      "Spacer": Spacer(flex: 1,),
      'DocumentUpload': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: DocumentUpload(
          docFormatList: params?.options ?? ['pdf', 'jpeg', 'jpg', 'png'],
          limitSize: params?.doubleValue ?? 5000,
          url: "${appConfig[BASE_URL_KEY]}${params?.url ?? ""}",
          header: StartupUtils.getHeader(mFormData: formData),
          body: {
            "appNumber": formData.getValue(key: 'appNumber'),
            "flow": params?.uploadFlow ?? formData.getValue(key: 'flow')
          },
          title: title,
          subTitle: subTitle,
          btnText: 'SUBMIT',
          isManulaDetailsButtonRequired:
              params?.isManualDetailsButtonRequired ?? false,
          manualDetailsButtonTitle: params?.manualDetailsButtonTitle,
          isFileTypePDF: params?.isTypePDF ?? false,
          onSubmitPressed: () {
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: BUTTON,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );
          },
          onUploadIconPressed: () {
            NativeAnalyticsHelper.shared.logEventWith(params?.native_analytic_types,params?.native_analytic_event_name, params?.native_analytic_event_action, context);
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: CARD,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );

            // debugPrint(
            //     'onUploadIconPressed is $id $analyticID and ${action?.analytic_id}');
          },
          onSuccess: (status, response, imgPath) {
            if(AnalyticHelper.flowValue == "pan" || AnalyticHelper.flowValue == "panUpload"){
              NativeAnalyticsHelper.shared.logEventWith(["firebase", "clevertap", "appsflyer"],"KYC_PAN_Card_Submit","kyc_pan_card_submit", context);
            }
            formData.setValue(key: id, value: imgPath);

            Map msg = json.decode(response.toString());
            Map<String, dynamic> metadata = {
              "url": '',
              "status": 'success',
              "message":
                  '${msg["action"]["type"]} to ${msg["action"]["value"]["name"]}',
            };

            AnalyticHelper.logApiEvent(id, analyticID, metadata);

            WidgetActionHandler.handleActionAPI(
                context: context, screenId: currentScreen, response: response);
          },
          onError: (status, error) {
            print('onError----$status--------$error');

            Map<String, dynamic> metadata = {
              "url": '',
              "status": 'fail',
              "message": error,
              "errorType": "Backend"
            };

            AnalyticHelper.logApiEvent(id, analyticID, metadata);
          },
          isLoading: (formData.getValue(key: id + ':loading') == 'false' ||
                  formData.getValue(key: id + ':loading') == null)
              ? false
              : true,
          onManualDetailsPressed: () {
            debugPrint("==== ENTER MANUALLY CALLED UPLOAD====");

            debugPrint(
                'onManualDetailsPressed is $id $analyticID and ${action?.analytic_id}');
            NativeAnalyticsHelper.shared.logEventWith(params?.native_analytic_types_optional,params?.native_analytic_event_name_optional, params?.native_analytic_event_action_optional, context);
            AnalyticHelper.logClickEvent(
              analyticID: analyticID,
              component: TEXT,
              id: id,
              metaData: {},
              flowvalue: formData.getValue(key: 'flow'),
            );

            WidgetActionHandler.handleAction(
                context: context,
                screenId: currentScreen,
                action: action,
                id: id,
                analyticID: analyticID,
                analytic_metaData: analytic_metaData);
          },
        ),
      ),
      'InfoWidget': Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Info_widget(
            title: title, imageName: params?.placeholder ?? 'info.png'),
      ),
      "Divider": Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Container(height: 0.5, color: Colors.white),
      ),
      "Digilocker": Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Container(
          height:800,
          child: DigilockerWebView(
            callback: (hmac, code, state, err_discr, err) {
              print("Rahul $hmac, $code, $state, $err, $err_discr");
              if (err == "" && err_discr == "") {
                Map<String, dynamic> body = {
                  "code": code,
                  "hmac": hmac,
                  "state": state,
                };
                formData.setValue(key: code, value: code);
                formData.setValue(key: hmac, value: hmac);
                formData.setValue(key: state, value: state);
                WidgetActionHandler.handleAction(
                    context: context,
                    screenId: currentScreen,
                    action: WidgetAction(
                        api: "/v1/kyc/aadhaar/digilocker",
                        type: "navigateWithAPI",
                        method: "POST",
                        bodyParameters: body),
                    analyticID: analyticID,
                    analytic_metaData: analytic_metaData,
                    id: id);
              } else {
                NavigationUtils.pop(
                    context:
                        context); //${StartupUtils.DefaultHeaders["X-source"]}
              }
            },
            url:
                "${appConfig[DIGILOCKER_URL_KEY]}?Source=KYC2&data=${formData.getValue(key: 'token') ?? ACCESS_TOKEN}Other_source=KYC2&Other_language=${StartupUtils.DefaultHeaders["Accept-Language"]}&Other_cleverTapId=${StartupUtils.DefaultHeaders["X-cleverTapId"]}&Other_appsFlyerId=${StartupUtils.DefaultHeaders["X-appsFlyerId"]}&other_appId=${StartupUtils.DefaultHeaders["X-appId"]}&Other_appVersion=${StartupUtils.DefaultHeaders["X-appVersion"]}&Other_platform=${StartupUtils.DefaultHeaders["X-platform"]}&Other_device=${StartupUtils.DefaultHeaders["X-device"]}&Other_deviceId=${StartupUtils.DefaultHeaders["X-appId"]}&Other_deviceOS=${StartupUtils.DefaultHeaders["X-platform"]}&Other_macAddress=${StartupUtils.DefaultHeaders["X-macAddress"]}&Other_ipAddress=${StartupUtils.DefaultHeaders["X-ipAddress"]}&Other_location=${StartupUtils.DefaultHeaders["X-location"]}",
          ),
        ),
      ),
      "ESign": Padding(
        padding: EdgeInsets.only(
          left: style?.padding?.left ?? 0,
          top: style?.padding?.top ?? 0,
          right: style?.padding?.right ?? 0,
          bottom: style?.padding?.bottom ?? 0,
        ),
        child: Container(
          height: 800,
          child: ESignWebView(
            callback: (status, message) {
              //WidgetRepo._webViewController = webViewController ;
              print("Rahul esign parameter $status, $message");
              if (status.toUpperCase() == "TRUE") {
                formData.setValue(key: "ESign", value: null);
                WidgetActionHandler.handleAction(
                  context: context,
                  screenId: currentScreen,
                  action: WidgetAction(
                      api: "/v1/kyc/esign/confirmation",
                      type: "navigateWithAPI",
                      method: "POST",
                      bodyParameters: {}),
                  analyticID: analyticID,
                  analytic_metaData: analytic_metaData,
                );
              } else if (message == "User cancelled") {
                NavigationUtils.pop(context: context);
              } else {
                formData.setValue(key: id, value: 'false');
              }
            }, //${StartupUtils.DefaultHeaders["X-source"]}
            url:
                "${appConfig[ESIGN_URL_KEY]}&source=spark&token=${formData.getValue(key: 'token') ?? ACCESS_TOKEN}",
          ),
        ),
      )
    };

    return widgetRepo.containsKey(widgetName)
        ? (widgetRepo[widgetName] ?? Text('Invalid widget'))
        : Text('$widgetName Widget not found');
  }
}
