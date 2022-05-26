import 'package:json_annotation/json_annotation.dart';
//{"status":"success","statusCode":"200",
// "result":{"live":"yes","liveness-score":"0.9991","to-be-reviewed":"no"}}



class HypervergeResponse {
  String status;
  String statusCode;
  HypervergeResult result;
  HypervergeResponse({ required this.status, required this.statusCode, required this.result});
  factory HypervergeResponse.fromJson(Map<String, dynamic> data) {
    final status = data['status']  ?? '';
    final statusCode = data['statusCode']  ?? '';
    final result =  HypervergeResult.fromJson(data['result']);
    return HypervergeResponse(status: status, statusCode: statusCode,result:result);
  }
}

class HypervergeResult {
  String live;
  String liveness_score;
  String to_be_reviewed;
  HypervergeResult({ required this.live, required this.liveness_score,required this.to_be_reviewed});
  factory HypervergeResult.fromJson(Map<String, dynamic> data) {
    final live = data['live'] ?? '';
    final liveness_score = data['liveness-score'] ?? '';
    final to_be_reviewed = data['to-be-reviewed'] ?? '';
    return HypervergeResult(live: live, liveness_score: liveness_score,to_be_reviewed:to_be_reviewed);
  }
}
