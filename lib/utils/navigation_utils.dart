import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyc2/utils/action_handler.dart';

class NavigationUtils {

  static List<String> navHistory = [];

  static pushNamed({required BuildContext context, required String route}){
    navHistory.add('PUSH-$route');
    if(WidgetActionHandler.isBottomsheetOpen){
      Navigator.pop(context);
    }
    Navigator.of(context).pushNamed(route).then((value) {
      navHistory.add('POP-$route');
    });
  }

  static pushReplacementNamed({required BuildContext context, required String route}){
    navHistory.add('PUSH-$route');
    Navigator.of(context).pushReplacementNamed(route).then((value) {
      navHistory.add('POP-$route');
    });
  }

  static popAndPushNamed({required BuildContext context, route}){
    Navigator.popAndPushNamed(context, route);
  }

  static pop({required BuildContext context}){
    if (Navigator.of(context).canPop()) {
      debugPrint("===== Navigator.of(context).canPop() IS TRUE ========");
      Navigator.of(context).pop();
    } else {
      debugPrint("===== Navigator.of(context).canPop() IS FALSE ========");
      SystemNavigator.pop();
    }
  }

  static popTimes({required BuildContext context, required int count}){
    for (int i=0;i<count;i++){
      Navigator.of(context).pop();
    }
  }
}