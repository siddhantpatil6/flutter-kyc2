
import 'package:flutter/cupertino.dart';

class PersistedFormController {
  static final Map<String, TextEditingController> _textEditionControllers = {};
  static final Map<String, FocusNode> _focusNodes = {};
  static final Map<String, bool> _checkBoxControllers = {};
  static int navIndex = 0;
  static final List<GlobalKey<FormState>> navKeyTree = [];
  static List<int> navIndexTree = [];
  static List<String> navScreenNameTree = [];

  // pop Back BottomSheet Lists
  static List<String> backCurrentNavKeyScreen = ["pan","bank","aadhaar","signature","selfie","income","occupation","bankCheque","digilocker","eSign","personal","bankStatement","appointment","panUpload","bankUPI","upi_user_banklist"];
  static List<String> backNavKeyScreen = ["bankCheque","bankChequeOCRConfirmation","aadhar_manual","aadhaarOCRConfirmation","signature","selfie","confirm_signature","eSign","bankStatement"];
  static List<String> doLaterNavKeyScreen = ["pan","panOCRConfirmation","panManual","digilocker","panUpload","panUploadOCRConfirmation","bankUPI"];
  static List<String> editBankNavKeyScreen = ["bank","bank_details_manual","upi_user_banklist"];
  static List<String> conditionalDoItLaterKeyScreen = ["aadhaar"];

  static void setTextEditingController(String key,TextEditingController controller) {
    _textEditionControllers[key] = controller;
  }

  static TextEditingController getTextEditingController(String key) {
      TextEditingController spareController = new TextEditingController();
      if(_textEditionControllers.containsKey(key) && _textEditionControllers[key].runtimeType == TextEditingController) {
        return _textEditionControllers[key]!;
      } else {
        _textEditionControllers[key] = spareController;
        return _textEditionControllers[key] ?? spareController;
      }
  }

  static FocusNode getFocusNode(String key) {
    FocusNode node = new FocusNode();
      if(_focusNodes.containsKey(key) && _focusNodes[key].runtimeType == FocusNode) {
        return _focusNodes[key]!;
      } else {
        _focusNodes[key] = node;
        return _focusNodes[key] ?? node;
      }
  }

  static GlobalKey<FormState> getFormKeys(int index) {
    GlobalKey<FormState> spareFormKey = GlobalKey<FormState>();
    if(navIndexTree.contains(index)) {
      return navKeyTree.elementAt(index);
    } else {
      navIndexTree.add(index);
      navKeyTree.add(spareFormKey);
      return navKeyTree.elementAt(index);
    }
  }

  static void setCheckBoxValue(String key,bool value){
    _checkBoxControllers[key] = value;
  }

  static bool getCheckBoxValue(String key){
      return _checkBoxControllers[key] ?? false;
  }
}