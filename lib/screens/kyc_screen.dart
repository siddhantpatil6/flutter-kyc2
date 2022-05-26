import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/utils/device_asset_path.dart';
import 'package:flutter_shared_widgets/widgets/icon_text_button.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/image_asset_cache_handler.dart';
import 'package:kyc2/utils/navigation_utils.dart';
import 'package:kyc2/utils/network_check_helper.dart';
import 'package:kyc2/utils/widget_repo.dart';
import 'package:kyc2/widgets/app_bar.dart';
import 'package:kyc2/widgets/dynamic_layout.dart';
import 'package:provider/provider.dart';

import '../analytics/native_analytic_helper.dart';

class KycScreen extends StatefulWidget {

  String screenId;
  int screenIndex;
  Flows screenData;
  Map<String,List<List<Layout>>>?  layouts;
  KycScreen({required this.screenId, required this.screenData, required this.layouts, required this.screenIndex});

  @override
  State<StatefulWidget> createState() {
    return KycScreenState();
  }
}

class KycScreenState extends State<KycScreen> with WidgetsBindingObserver {
  String? title;
  int? screenIndex;
  String? analyticID;
  String? analytic_events_metaData;
  List<String>? native_analytic_types;
  String? native_analytic_event_name;
  String? native_analytic_event_action;
  late List<List<Layout>> layout;
  ActionMenu? actionMenu;
  WidgetAction? onLoad;
  WidgetAction? onUnload;
  WidgetAction? onBack;
  @override
  void initState() {
    title = widget.screenData.title ?? '';
    analyticID = widget.screenData.analytic_id ?? '';
    native_analytic_types = widget.screenData.native_analytic_types;
    native_analytic_event_name = widget.screenData.native_analytic_event_name;
    native_analytic_event_action = widget.screenData.native_analytic_event_action;
    analytic_events_metaData = widget.screenData.analytic_event_metadata ?? '';
    layout = widget.screenData.layout;
    actionMenu = widget.screenData.action_menu;
    onLoad = widget.screenData.onLoad;
    onUnload = widget.screenData.onUnload;
    onBack = widget.screenData.onBack;
    WidgetRepo.layouts = widget.layouts;
    if(!PersistedFormController.navScreenNameTree.contains(widget.screenId)) {
      PersistedFormController.navScreenNameTree.add(widget.screenId);
      debugPrint("******** init state called in KYC Screen ${widget
          .screenId}********");
      debugPrint("******** initState Screen Tree ${PersistedFormController
          .navScreenNameTree}********");

      _checkNetworkanddownloadassetforCache();


      WidgetActionHandler.handleAction(
          context: context,
          screenId: widget.screenId,
          action: onLoad,
          analyticID: analyticID,
          analytic_metaData: analytic_events_metaData);



      List data = analyticID!.split("_");
      AnalyticHelper.flowValue = widget.screenId;
      AnalyticHelper.setURLandOtherDetails();

      if (data.length == 1)
        AnalyticHelper.logImpressionEvent(
            screenname: analyticID ?? "", idvalue: widget.screenId);

      NativeAnalyticsHelper.shared.logEventWith(native_analytic_types,native_analytic_event_name, native_analytic_event_action, context);
    }
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // app comes to foreground
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        //going background
        AnalyticHelper.forcePushdata();
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        //going background
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        //app crashes
        print("app in detached");
        break;
    }
  }

  @override
  void deactivate() {
    debugPrint(
        "******** deactivate state called in KYC Screen ${widget.screenId}********");
    WidgetActionHandler.handleAction(
        context: context,
        screenId: widget.screenId,
        action: onUnload,
        analyticID: analyticID,
        analytic_metaData: analytic_events_metaData);
    super.deactivate();
  }

  @override
  void activate() {
    debugPrint("******** activate state called in KYC Screen ${widget.screenId}********");
    super.activate();
  }

  @override
  void dispose() {
    PersistedFormController.navScreenNameTree.removeLast();
    debugPrint(
        "******** dispose state called in KYC Screen ${widget.screenId}********");
    debugPrint(
        "******** dispose Screen Tree ${PersistedFormController.navScreenNameTree}********");
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();

  }

  void _checkNetworkanddownloadassetforCache(){
    fetchNetworkPrefrence(bool isNetworkPresent) {
      if (isNetworkPresent) {
        debugPrint('yes network with path on kay screen call with count : ${AssetPath.downloaded_Count }');
        if((AssetPath.downloaded_Count < AssetPath.total_Count && AssetPath.isAllow) || AssetPath.downloaded_Count == 0 ){
          ImageAssetCacheHandler.instance.initData();
        }
      }else{
        AssetPath.isAllow = true;
      }
    }

    NetworkCheckHelper.checkInternet(fetchNetworkPrefrence);
  }
  void initFormController(){

  }

  @override
  void didUpdateWidget(covariant KycScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("******** didUpdateWidget state called in KYC Screen ${widget.screenId}********");
  }

  Future<bool> _onWillPop() {
    debugPrint(
        "====== ON WILL POP OF FORM CALLED ======= ${PersistedFormController.navScreenNameTree.length} and widget.screenId is ${widget.screenId}");

    AnalyticHelper.logBackPressEvent(widget.screenId, analyticID ?? "", 'device');
    if (PersistedFormController.navScreenNameTree.length == 1) {
      AnalyticHelper.forcePushdata();
     // NavigationUtils.pop(context: context);
      WidgetActionHandler.handleAction(
          context: context,
          screenId: widget.screenId,
          action: WidgetAction(
              api: "BackDoItLater",
              type: "openBotomSheet",
              layoutId: "BackDoItLater"),
          analyticID: "bs-doyouwanttoleave",
          analytic_metaData: "screen:${widget.screenId},");
      return Future.value(false);
    }

    if (onBack != null) {
      WidgetActionHandler.handleAction(
          context: context,
          screenId: widget.screenId,
          action: onBack,
          analyticID: "onback",
          analytic_metaData: analytic_events_metaData);
      return Future.value(false);
    } else {
      if (widget.screenId == "thanks") {
        WidgetActionHandler.handleAction(
            context: context,
            screenId: widget.screenId,
            action: WidgetAction(api: "exitkyc", type: "openCallback"),
            analyticID: analyticID,
            analytic_metaData: analytic_events_metaData);
      } else if (PersistedFormController.backNavKeyScreen.contains(
          PersistedFormController.navScreenNameTree.elementAt(
              PersistedFormController.navScreenNameTree.length - 2))) {
        if (PersistedFormController.backCurrentNavKeyScreen
            .contains(widget.screenId))
          WidgetActionHandler.handleAction(
              context: context,
              screenId: widget.screenId,
              action: WidgetAction(
                  api: "Back", type: "openBotomSheet", layoutId: "Back"),
              analyticID: analyticID,
              analytic_metaData: analytic_events_metaData);
      } else if (PersistedFormController.doLaterNavKeyScreen.contains(
          PersistedFormController.navScreenNameTree.elementAt(
              PersistedFormController.navScreenNameTree.length - 2))) {
        if (PersistedFormController.backCurrentNavKeyScreen
            .contains(widget.screenId))
          WidgetActionHandler.handleAction(
              context: context,
              screenId: widget.screenId,
              action: WidgetAction(
                  api: "BackDoItLater",
                  type: "openBotomSheet",
                  layoutId: "BackDoItLater"),
              analyticID: "bs-doyouwanttoleave",
              analytic_metaData: "screen:${widget.screenId},");
      } else if (PersistedFormController.editBankNavKeyScreen.contains(
          PersistedFormController.navScreenNameTree.elementAt(
              PersistedFormController.navScreenNameTree.length - 2))) {
        if (PersistedFormController.backCurrentNavKeyScreen
            .contains(widget.screenId))
          WidgetActionHandler.handleAction(
              context: context,
              screenId: widget.screenId,
              action: WidgetAction(
                  api: "BackEditBank",
                  type: "openBotomSheet",
                  layoutId: "BackEditBank"),
              analyticID: "bs-doyouwanttoleave",
              analytic_metaData: "screen:${widget.screenId},");
      } else if (PersistedFormController.conditionalDoItLaterKeyScreen.contains(
          PersistedFormController.navScreenNameTree.elementAt(
              PersistedFormController.navScreenNameTree.length - 2))) {
        if (PersistedFormController.backCurrentNavKeyScreen
                .contains(widget.screenId) &&
            FormData().getValue(key: "poaType") == "digilocker")
          WidgetActionHandler.handleAction(
              context: context,
              screenId: widget.screenId,
              action: WidgetAction(
                  api: "BackDoItLater",
                  type: "openBotomSheet",
                  layoutId: "BackDoItLater"),
              analyticID: "bs-doyouwanttoleave",
              analytic_metaData: "screen:${widget.screenId},");
        else if (PersistedFormController.backCurrentNavKeyScreen
            .contains(widget.screenId))
          WidgetActionHandler.handleAction(
              context: context,
              screenId: widget.screenId,
              action: WidgetAction(
                  api: "Back", type: "openBotomSheet", layoutId: "Back"),
              analyticID: analyticID,
              analytic_metaData: analytic_events_metaData);
      } else {
        return Future.value(true);
      }
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screenId == "email" &&
        Platform.isAndroid &&
        FormData().getValue(key: "AutoPickedEmailHardCodeKey") != "true") {
      WidgetActionHandler.getAutoPickedUpAndroidResult(
          context: context,
          screenId: widget.screenId,
          analyticid: analyticID,
          analytic_meta_Data: analytic_events_metaData);
    }
    // disable the Loader in CTA if still loading
    FormData().clearFlagValue(':loading');

    var rightToolbarIcon = actionMenu != null
        ? IconTextParams(
            icon: actionMenu!.icon,
            title: actionMenu!.title,
            onPress: () {
              debugPrint(
                  'arrow is analyticID and id $analyticID and ${actionMenu!.action!.layoutId!.toLowerCase()}');

              AnalyticHelper.logClickEvent(
                analyticID: analyticID ?? "",
                component: TEXT,
                id: actionMenu!.action!.layoutId!.toLowerCase(),
              );

              WidgetActionHandler.handleAction(
                  context: context,
                  action: actionMenu?.action,
                  screenId: widget.screenId,
                  analyticID: actionMenu?.action!.analytic_id!,
                  analytic_metaData: analytic_events_metaData);
            })
        : null;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: (widget.screenData.requireAppBar != null)
            ? (widget.screenData.requireAppBar!.contains("false")
            ? null
            : KycAppBar(
            title: title,
            screenId: widget.screenId,
            rightIcon: rightToolbarIcon))
            : KycAppBar(
          title: title,
          screenId: widget.screenId,
          rightIcon: rightToolbarIcon,
          analyticID: analyticID ?? "",
        ),
        body: Container(
          child: SingleChildScrollView(
              child: SafeArea(
                  child: Container(
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          onWillPop: _onWillPop,
                          key: PersistedFormController.getFormKeys(widget.screenIndex),
                          child: DynamicLayout(
                            screenId: widget.screenId,
                            layout: layout,
                            screenIndex: widget.screenIndex,
                            analyticID: analyticID,
                            analytic_metaData: analytic_events_metaData,
                          ),
                        )),
                  ))),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ));
  }
}