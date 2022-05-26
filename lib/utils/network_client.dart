import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/widgets/custom_toast.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kyc2/constants/strings.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/models/http_error.dart';
import 'package:kyc2/utils/analytic_helper.dart';
import 'package:kyc2/utils/from_data.dart' as form;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api.dart';
import 'navigation_utils.dart';

const Map<String, String> defaultParam = {};

class NetworkClient {
  http.Client client = http.Client();
  final String baseUrl;
  Map<String, String>? headers;
  int retryCount;
  int retryMilliseconds;

  NetworkClient(
      {required this.baseUrl,
      this.headers = defaultParam,
      this.retryCount = 0,
      this.retryMilliseconds = 0}) {
    Iterable<Duration> retryDurations = [
      Duration(milliseconds: retryMilliseconds),
      Duration(milliseconds: retryMilliseconds * 2),
      Duration(milliseconds: retryMilliseconds * 3),
    ];

    this.client = RetryClient.withDelays(http.Client(), retryDurations);
  }

  Future<http.Response> getData({
    required String url,
    Map<String, String>? headers,
    required WidgetAction action,
    required form.FormData mFormData,
  }) async {
    String value = '';
    int index = 0;
    action.queryParameters?.forEach((key, val) {
      if (key != SUB_ID) {
        if (key != ID) {
          value = (index == 0)
              ? '?' + key + '=${mFormData.getValue(key: val)}'
              : value + '&' + key + '=${mFormData.getValue(key: val)}';
          index++;
        }
      }
    });
    String requestUrl = baseUrl + url + value;
    requestUrl = Uri.encodeFull(requestUrl);
    debugPrint('requestUrl -> $requestUrl and $headers');
    Uri requestUri = Uri.parse(requestUrl);
    if (headers != null) {
      this.headers?.addAll(headers);
    }
    var response = await client.get(requestUri, headers: this.headers);
    return response;
  }

  Future<http.Response> get(
      {required String url, Map<String, String>? headers}) async {
    String requestUrl = baseUrl + url;
    Uri requestUri = Uri.parse(requestUrl);
    if (headers != null) {
      this.headers?.addAll(headers);
    }
    var response = await client.get(requestUri, headers: this.headers);
    return response;
  }

  Future<http.Response> post(
      {required String url,
      Map<String, String>? headers,
      required String body}) async {
    String requestUrl = baseUrl + url;
    Uri requestUri = Uri.parse(requestUrl);
    if (headers != null) {
      this.headers?.addAll(headers);
    }

    debugPrint("=============== REQUEST START =======================");
    debugPrint("METHOD : POST");
    debugPrint("URL : " + requestUrl);
    debugPrint("HEADERS : " + this.headers.toString());
    debugPrint("BODY : " + body);
    debugPrint("================ REQUEST END ======================");

    var response =
        await client.post(requestUri, headers: this.headers, body: body);

    debugPrint("=============== RESPONSE START =======================");
    debugPrint("METHOD : POST");
    debugPrint("HEADERS : " + response.headers.toString());
    debugPrint("BODY : " + response.body.toString());
    debugPrint("================ RESPONSE END ======================");
    return response;
  }

  Future<http.Response> postUPI(
      {required String url,
        Map<String, String>? headers,
        required Object body}) async {
    String requestUrl = appConfig[UPI_URL]+ url;
    Uri requestUri = Uri.parse(requestUrl);
    if (headers != null) {
      this.headers?.addAll(headers);
    }

    debugPrint("=============== REQUEST START =======================");
    debugPrint("METHOD : POST");
    debugPrint("URL : " + requestUrl);
    // debugPrint("HEADERS : " + this.headers.toString());
    debugPrint("BODY : " + body.toString());
    debugPrint("================ REQUEST END ======================");

    var response =
    await client.post(requestUri, body: body);

    debugPrint("=============== RESPONSE START =======================");
    debugPrint("METHOD : POST");
    // debugPrint("HEADERS : " + response.headers.toString());
    debugPrint("BODY : " + response.body.toString());
    debugPrint("================ RESPONSE END ======================");

    // var str='';
    // if(url=="/upibank/get_bank_account_detail"){
    //   str='{"status" :true,"message": "error message if any","data": [{"account_number": "018990100005269","account_type": "SAVINGS","account_ifsc": "YESB0000189","account_holder": "NIKHIL D  BHEDA"},{"account_number": "123454321","account_type": "SAVINGS","account_ifsc": "YESB0000189","account_holder": "NIKHIL D  BHEDA"}]}';
    // }else if(url=='/upibank/get_bank_list'){
    //    str=response.body.toString();
    // }
    //
    // http.Response hardCoded = new http.Response(str,300);
    
    return response;
  }

  postImage(
      {required String url,
      required WidgetAction action,
      Map<String, String>? headers,
      required form.FormData mFormData,
      required BuildContext context,
      String? id,
      String? analyticID}) async {
    String requestUrl = baseUrl + url;
    if (headers != null) {
      var token = mFormData.getValue(key: 'token');
      headers['Authorization'] = 'Bearer $token';
      this.headers?.addAll(headers);
    }
    var request = Dio();
    Map<String, String> fileMap = {};
    Map<String, dynamic> data = {};
    action.bodyParameters?.forEach((key, value) {
      if (key.contains(':')) {
        String fileKey = key.substring(0, key.indexOf(":"));
        fileMap[fileKey] = value;
        return;
      }
      if(key == "flow") {
        data[key] = value;
      }else{
        data[key] =  mFormData.getValue(key: value);
      }
    });

    Map<String, dynamic> eBody = {
      "appNumber": mFormData.getValue(key: 'appNumber'),
    };

    Map<String, dynamic> tempMap = {};
    for (var entry in fileMap.entries) {
      if(mFormData.getValue(key: entry.value).contains('https:')){
        final response = await http.get(Uri.parse(mFormData.getValue(key: entry.value)));

        final documentDirectory = await getApplicationDocumentsDirectory();

        final file = File(join(documentDirectory.path, 'imagetest.png'));

        file.writeAsBytesSync(response.bodyBytes);
        tempMap[entry.key] = await MultipartFile.fromFile(
          file.path,
          contentType: new MediaType("image", "jpeg"), //add this
        );
      }else{
        tempMap[entry.key] = await MultipartFile.fromFile(
          mFormData.getValue(key: entry.value),
          contentType: new MediaType("image", "jpeg"), //add this
        );
      }
    }

    eBody.addAll(data);
    eBody.addAll(tempMap);

    debugPrint("=============== Image Check START =======================");
    debugPrint("=============== REQUEST START =======================");
    debugPrint("METHOD : POST");
    debugPrint("URL : " + requestUrl);
    debugPrint("HEADERS : " + this.headers.toString());
    debugPrint("BODY : " + eBody.toString());
    debugPrint("================ REQUEST END ======================");
    debugPrint("=============== Image Check End =======================");

    FormData formData = new FormData.fromMap(eBody);

    var response = await request.post(
      requestUrl,
      data: formData,
      options: Options(
        headers: this.headers,
      ),
      onSendProgress: (int sent, int total) {
        debugPrint("sent${sent.toString()}" + " total${total.toString()}");
      },
    ).whenComplete(() {
      debugPrint("complete:");
    }).catchError((onError) {
      debugPrint("error.response:${onError.response.toString()}");
      debugPrint("error:${onError.toString()}");
      // disabling the Loader in Button CTA
      mFormData.clearFlagValue(':loading');
      Map msg = json.decode(onError.response.toString());
      Map<String, dynamic> metadata = {
        "url": requestUrl,
        "status": 'fail',
        "message": msg["message"].toString(),
        "errorType": "Backend"
      };
      AnalyticHelper.logApiEvent(id!, analyticID ?? "", metadata);

      if (action.postNavigate != null)
        NavigationUtils.pushNamed(
            context: context, route: action.postNavigate ?? '');
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(jsonDecode(onError.response.toString())["message"].toString()),
      // ));
      CustomToast.showToast(
          context: context,
          msg: jsonDecode(onError.response.toString())["message"].toString());
    });

    debugPrint("=============== RESPONSE START =======================");

    debugPrint("Response Header : " + response.headers.toString());
    debugPrint("Response Data : " + response.data.toString());
    debugPrint("Response Body : " + response.toString());

    debugPrint("=============== RESPONSE END =======================");

    return response.data;
  }

  void close() {
    client.close();
  }
}
