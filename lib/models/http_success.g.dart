// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpStatus _$HttpStatusFromJson(Map<String, dynamic> json) {
  return HttpStatus(
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$HttpStatusToJson(HttpStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

SaveSuccess _$SaveSuccessFromJson(Map<String, dynamic> json) {
  return SaveSuccess(
    status: json['status'] as String,
    action: HttpSuccessAction.fromJson(json['action'] as Map<String, dynamic>),
    token: json['token'] as String?,
    data: json['data'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$SaveSuccessToJson(SaveSuccess instance) =>
    <String, dynamic>{
      'status': instance.status,
      'token': instance.token,
      'data': instance.data,
      'action': instance.action,
    };

SaveUPIBank _$SaveUPIBankFromJson(Map<String, dynamic> json) {
  return SaveUPIBank(
    status: json['status'] as bool,
    message: json['message'] as String?,
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
  );
}

Map<String, dynamic> _$SaveUPIBankToJson(SaveUPIBank instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

HttpSuccessAction _$HttpSuccessActionFromJson(Map<String, dynamic> json) {
  return HttpSuccessAction(
    type: json['type'] as String,
    value: _ActionValue.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$HttpSuccessActionToJson(HttpSuccessAction instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };

_ActionValue _$_ActionValueFromJson(Map<String, dynamic> json) {
  return _ActionValue(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$_ActionValueToJson(_ActionValue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
