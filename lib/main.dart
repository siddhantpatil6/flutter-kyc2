import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shared_widgets/utils/cdn_url.dart';
import 'package:flutter_shared_widgets/utils/device_asset_path.dart';
import 'package:flutter_shared_widgets/utils/theme_manager.dart';
import 'package:hypersnapsdk_flutter/HVHyperSnapParams.dart';
import 'package:hypersnapsdk_flutter/HyperSnapSDK.dart';
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/screens/kyc_screen.dart';
import 'package:kyc2/screens/landing.dart';
import 'package:kyc2/models/config_model.dart';
import 'package:kyc2/utils/action_handler.dart';
import 'package:kyc2/utils/config_utils.dart';
import 'package:kyc2/utils/form_controller.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/image_asset_cache_handler.dart';
import 'package:kyc2/utils/network_check_helper.dart';
import 'package:kyc2/utils/network_client.dart';
import 'package:http/http.dart' as http;
import 'package:kyc2/utils/startup_utils.dart';
import 'package:kyc2/utils/widget_repo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<FormData>(
      create: (context) => FormData(),
      child: KycApp(),
    ),
  );
}

class KycApp extends StatefulWidget {
  KycApp(
  {Key? key, this.futterCallback}):super(key: key);
  Function(Map<String,String>)? futterCallback;
  @override
  State<StatefulWidget> createState() {
    WidgetActionHandler.futterToFlutterCallback = futterCallback;
    return _KycAppState();
  }
}

class _KycAppState extends State<KycApp> {
  Future<GetFlows>? flowsResponse;
  TextEditingController mobileNo = new TextEditingController();
  Map<String, WidgetBuilder> routeTable = {};
  String? _mobilenum, _guestToken, _referralCode,_deviceInfo,_ipAddressInfo;
  late Map _mapData;
  late SharedPreferences _sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GetFlows>(
      future: flowsResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          debugPrint("== HAS DATA == : " + snapshot.hasData.toString());
          debugPrint("== APP NO == : " + snapshot.data!.appNumber.toString());
          debugPrint("== EVENTS == : " + snapshot.data!.events.toString());
          debugPrint("== ACTION == : " + snapshot.data!.action.toString());

          Future.delayed(Duration.zero, () async {
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "appNumber", value: snapshot.data?.appNumber);
            Provider.of<FormData>(context, listen: false).setValue(
                key: "actionId", value: snapshot.data?.action.value.id ?? '');
            if (snapshot.data?.data["documents"] != null) {
              WidgetRepo.documentsData = snapshot.data?.data["documents"]!;
            }
            debugPrint(snapshot.data?.data.toString());
            final Map<String, dynamic> eventData = snapshot.data!.events.data;
            /*
              Below forEach presets form values for next launch
           */
            eventData.forEach((key, value) {
              if (key == "isESign") {
                WidgetRepo.isEsign = value as bool;
              }
              StartupUtils.preFillForm(
                  context: context, key: key, value: value);
            });
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "mobile", value: _mobilenum);
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "token", value: _guestToken);
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "referralCode", value: _referralCode);
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "DEVICE_ID", value: _deviceInfo);
            Provider.of<FormData>(context, listen: false)
                .setValue(key: "IP_ADDRESS", value: _ipAddressInfo);
            PersistedFormController.getTextEditingController("mobile").text =
                _mobilenum ?? '';
            PersistedFormController.getTextEditingController("referralCode")
                .text = _referralCode ?? '';
          });

          routeTable['/'] = (context) => LandingScreen(snapshot.data!);
          /*
              Below forEach creates new screens dynamically from start api flows
           */
          snapshot.data?.flows.entries.forEach((element) {

            if(element.value.layout[0][0].component == 'ProgressHeader'){
              StartupUtils.screenProgressMap [element.key]  =  element.value.layout[0][0].params?.doubleValue.toString() ?? '' ;
            }

            final String _routeKey = '/${element.key}';
            if (routeTable.containsKey(_routeKey)) {
              debugPrint("Received a conflicting key " + _routeKey);
              return;
            } else {
              final String screenId = element.value.flow ?? element.key;

              routeTable[_routeKey] = (context) => kDebugMode
                  ? GestureDetector(
                  onTap: () {
                   // FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: KycScreen(
                      screenId: screenId,
                      screenData: element.value,
                      layouts: snapshot.data?.layouts,
                      screenIndex: PersistedFormController.navIndex++))
                  : ChangeNotifierProvider<FormData>(
                create: (context) => FormData(),
                child: GestureDetector(
                    onTap: () {
                    //  FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: KycScreen(
                        screenId: screenId,
                        screenData: element.value,
                        layouts: snapshot.data?.layouts,
                        screenIndex: PersistedFormController.navIndex++)),
              );
            }
          });

          return new MaterialApp(
            key: Key("home"),
            title: 'KYC',
            theme: ThemeManager.shared.light,
            darkTheme: ThemeManager.shared.dark,
            initialRoute: '/',
            routes: routeTable,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
          /*
          // For Test login purpose only
          debugPrint("DOES NOT HAVE DATA : " + snapshot.toString());
          return MaterialApp(
            key: Key("login"),
            theme: ThemeManager.shared.light,
            darkTheme: ThemeManager.shared.dark,
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: KycAppBar(title: 'Login', screenId: 'login-screen'),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Form(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: InputField(
                                        title: 'Enter Mobile number',
                                        hint: 'Enter Mobile number',
                                        keyboardType: InputFieldKeyboardtype.number,
                                        controller: mobileNo,
                                        onChange: (value) {
                                          Provider.of<FormData>(context,
                                              listen: false)
                                              .setValue(key: 'mobile', value: value);
                                        },
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                          top: 60,
                                        ),
                                        child: CustomButton(
                                          title: 'Login',
                                          isLoadType: false,
                                          onPressed: () {
                                            doLogin();
                                          },
                                          isLoading: false,
                                        )),
                                  ],
                                ))),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0)),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                )),
          );
          */
        }
      },
    );
  }

  void initHyperSnapSDK() async {
    // TODO: Add appId and appKey
    var appID = "2d0d7a";
    var appKey = "75b8cbab563da3c508ed";
    await HyperSnapSDK.initialize(appID, appKey,
        (await HVHyperSnapParams.getValidParams())["RegionIndia"]);
  }

  @override
  void initState() {
    super.initState();
    initHyperSnapSDK();
    initSharedData();
    //initCacheAsset();
    //CDNUrl.cdn_url = appConfig[BASE_URL_CDN_KEY];
  }

  Future<bool> _initConfig(String env) async {
    try{
       String path = await rootBundle.loadString('packages/kyc2/js/config/${env.toLowerCase()}.json');
       var data = await json.decode(path);
       if(data == null){
        path = await rootBundle.loadString('packages/kyc2/js/config/prod.json');
        data = await json.decode(path);
      }
      appConfig = data;
    }catch(ex){
      debugPrint("Failed to load config, setting prod env \n Exception:- $ex");
      final String path = await rootBundle.loadString('packages/kyc2/js/config/prod.json');
      final data = await json.decode(path);
      appConfig = data;
    }
    CDNUrl.cdn_url = appConfig[BASE_URL_CDN_KEY];
    initCacheAsset();
    return true;
  }

  void initSharedData() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (_sharedPreferences.getString("mapData")?.isNotEmpty ?? false) {
      _mapData = json.decode(_sharedPreferences.getString("mapData").toString());
      _mapData['uuid'] = Uuid().v1();
      ConfigSingleTon.instance.configData = ConfigModel.fromJson(_mapData);
      await _initConfig(ConfigSingleTon.instance.configData?.envType.toString() ?? "");
      _mobilenum = ConfigSingleTon.instance.configData?.mobileNumber;
      _guestToken = ConfigSingleTon.instance.configData?.guestToken;
      _deviceInfo = ConfigSingleTon.instance.configData?.device;
      _ipAddressInfo = ConfigSingleTon.instance.configData?.ipAddress;
      _referralCode = ConfigSingleTon.instance.configData?.rneUrl.split("::").first.split('=').last.trim();

      Provider.of<FormData>(context, listen: false).setValue(key: 'rneUrl', value: ConfigSingleTon.instance.configData?.rneUrl ?? '');
      setState(() {
        flowsResponse = getFlows(_guestToken ?? "");
      });
    }
  }

  void initCacheAsset(){
    fetchNetworkPrefrence(bool isNetworkPresent) {
      print('my log isNetworkPresent = $isNetworkPresent ');
      if (isNetworkPresent) {
        print('my log ->isNetworkPresent: main ${AssetPath.downloaded_Count} out of ${AssetPath.total_Count}');
        if((AssetPath.downloaded_Count < AssetPath.total_Count && AssetPath.isAllow) || AssetPath.downloaded_Count == 0 ){
          ImageAssetCacheHandler.instance.initData();
        }

      }else{
        AssetPath.isAllow = true;
      }
    }
    NetworkCheckHelper.checkInternet(fetchNetworkPrefrence);
  }

  Future<GetFlows> readJson() async {
    final String flowsResponseString =
    await DefaultAssetBundle.of(context).loadString("flows.json");
    flowsResponse =
        Future.value(GetFlows.fromJson(jsonDecode(flowsResponseString)));
    return flowsResponse!;
  }

  Future<GetFlows> getFlows(String token) async {
    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer $token';
    headers.addAll(StartupUtils.DefaultHeaders);
    NetworkClient networkClient = new NetworkClient(
      baseUrl: appConfig[BASE_URL_KEY],
      retryMilliseconds: RETRY_MILLISECONDS,
      headers: headers,
    );

    http.Response response =
    await networkClient.post(url: START_API_ENDPOINT, body: '');

    if (response.statusCode == 200) {
      flowsResponse = Future.value(GetFlows.fromJson(jsonDecode(response.body)));
      //flowsResponse = readJson();
      return flowsResponse!;
    } else {
      throw Exception('Failed to load album');
    }
  }

  /*
  // For Test Login purpose only
  doLogin() async {
    debugPrint("logging you in using mobile : " + mobileNo.text);

    NetworkClient networkClient = new NetworkClient(
      baseUrl: appConfig[BASE_URL_KEY],
      retryMilliseconds: RETRY_MILLISECONDS,
      headers: StartupUtils.DefaultHeaders,
    );

    var loginBody = {};
    loginBody["country_code"] = "+91";
    loginBody["mob_no"] = "${mobileNo.text}";
    loginBody["user_id"] = "naruto";
    loginBody["source"] = "SPARK";
    loginBody["app_id"] = "1298";
    debugPrint("loginBody----> :" + loginBody.toString());
    var result = await networkClient.post(
        url: '/internal/token', body: json.encode(loginBody));

    var token = jsonDecode(result.body)['token'];
    debugPrint("RESULT FOUND $token ====");

    Provider.of<FormData>(context, listen: false)
        .setValue(key: 'token', value: token.toString());

    await getFlows(token.toString());
    setState(() {
      flowsResponse;
    });
  }
  */
 }
