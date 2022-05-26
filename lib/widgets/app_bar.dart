import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shared_widgets/constants/dimensions.dart';
import 'package:flutter_shared_widgets/widgets/icon_text_button.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/navigation_utils.dart';

class KycAppBar extends StatelessWidget implements PreferredSizeWidget{

  final String? title;
  final IconTextParams? rightIcon;
  final String screenId;
  final String? analyticID;
  final String? analytic_meta_data;
  KycAppBar({
    required this.screenId,
    this.title,
    this.rightIcon,
    this.analyticID,
    this.analytic_meta_data,
  });

  @override
  Widget build(BuildContext context) {

    var appBarActions = <Widget>[];
    if(rightIcon != null){
      appBarActions.add(IconTextButton(icon: rightIcon!.icon, title: rightIcon!.title, onPress: rightIcon!.onPress));
    }
    return  AppBar(
      title: Text(title ?? '', style: Theme.of(context).textTheme.headline6),
      backgroundColor:Colors.transparent,
      elevation: 0,
      backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).backgroundColor),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Theme.of(context).textTheme.headline1?.color,
        onPressed: () {
          debugPrint('custom app bar back button pressed');
          debugPrint(
              'app bar screenId is $screenId and analyticID is $analyticID');
          List data = analyticID!.split("_");
          if (data.length == 1)
            AnalyticHelper.logBackPressEvent(
                screenId, analyticID ?? "", 'appback');
          if (PersistedFormController.navScreenNameTree.length == 1) {
            if (screenId == "register") {
              // WidgetActionHandler.handleAction(
              //     context: context,
              //     screenId: screenId,
              //     action: WidgetAction(
              //         api: "moveToMain",
              //         type: "navigateToHost",
              //         layoutId: "Back"));
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: screenId,
                  action: WidgetAction(
                      api: "BackDoItLater",
                      type: "openBotomSheet",
                      layoutId: "BackDoItLater"),
                  analyticID: "bs-doyouwanttoleave",
                  analytic_metaData: "screen:${screenId},");
            }
           // NavigationUtils.pop(context: context);
            return;
          }
          if (PersistedFormController.backNavKeyScreen.contains(
              PersistedFormController.navScreenNameTree.elementAt(
                  PersistedFormController.navScreenNameTree.length - 2))) {
            if (PersistedFormController.backCurrentNavKeyScreen
                .contains(screenId))
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: screenId,
                  action: WidgetAction(
                      api: "Back", type: "openBotomSheet", layoutId: "Back"),
                  analyticID: "bs-doyouwanttoleave",
                  analytic_metaData: "screen:$screenId,");
            else
              NavigationUtils.pop(context: context);
          } else if (PersistedFormController.doLaterNavKeyScreen.contains(
              PersistedFormController.navScreenNameTree.elementAt(
                  PersistedFormController.navScreenNameTree.length - 2))) {
            if (PersistedFormController.backCurrentNavKeyScreen
                .contains(screenId))
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: screenId,
                  action: WidgetAction(
                      api: "BackDoItLater",
                      type: "openBotomSheet",
                      layoutId: "BackDoItLater"),
                  analyticID: "bs-doyouwanttoleave",
                  analytic_metaData: "screen:$screenId,");
            else
              NavigationUtils.pop(context: context);
          } else if (PersistedFormController.editBankNavKeyScreen.contains(
              PersistedFormController.navScreenNameTree.elementAt(
                  PersistedFormController.navScreenNameTree.length - 2))) {
            if (PersistedFormController.backCurrentNavKeyScreen
                .contains(screenId))
              WidgetActionHandler.handleAction(
                  context: context,
                  screenId: screenId,
                  action: WidgetAction(
                      api: "BackEditBank",
                      type: "openBotomSheet",
                      layoutId: "BackEditBank"),
                  analyticID: "bs-doyouwanttoleave",
                  analytic_metaData: "screen:$screenId,");
            else
              NavigationUtils.pop(context: context);
          } else
            NavigationUtils.pop(context: context);
        },
      ),
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(STATUS_BAR_HEIGHT);
}
