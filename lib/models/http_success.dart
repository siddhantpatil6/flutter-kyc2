import 'package:json_annotation/json_annotation.dart';
part 'http_success.g.dart';

@JsonSerializable()
class HttpStatus {
  final String status;

  HttpStatus({required this.status});
  factory HttpStatus.fromJson(Map<String,dynamic> data) => _$HttpStatusFromJson(data);
  Map<String,dynamic> toJson() => _$HttpStatusToJson(this);
}

@JsonSerializable()
class SaveSuccess {
  final String status;
  final String? token;
  final Map<String, dynamic>? data;
  final HttpSuccessAction action;

  SaveSuccess({required this.status, required this.action, this.token, this.data});
  factory SaveSuccess.fromJson(Map<String,dynamic> data) => _$SaveSuccessFromJson(data);
  Map<String,dynamic> toJson() => _$SaveSuccessToJson(this);
}

@JsonSerializable()
class SaveUPIBank {
  final bool status;
  final String? message;
  final List<Map<String, dynamic>>? data;

  SaveUPIBank({required this.status,  this.message, this.data});
  factory SaveUPIBank.fromJson(Map<String,dynamic> data) => _$SaveUPIBankFromJson(data);
  Map<String,dynamic> toJson() => _$SaveUPIBankToJson(this);
}

@JsonSerializable()
class HttpSuccessAction {
  final String type;
  final _ActionValue value;

  HttpSuccessAction({required this.type, required this.value});
  factory HttpSuccessAction.fromJson(Map<String,dynamic> data) => _$HttpSuccessActionFromJson(data);
  Map<String,dynamic> toJson() => _$HttpSuccessActionToJson(this);
}

@JsonSerializable()
class _ActionValue {
  final String id;
  final String name;

  _ActionValue({required this.id, required this.name});
  factory _ActionValue.fromJson(Map<String,dynamic> data) => _$_ActionValueFromJson(data);
  Map<String,dynamic> toJson() => _$_ActionValueToJson(this);
}