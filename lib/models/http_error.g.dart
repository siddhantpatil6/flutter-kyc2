// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpError _$HttpErrorFromJson(Map<String, dynamic> json) {
  return HttpError(
    code: json['code'] as String,
    message: json['message'] as String,
    details: json['details'],
  );
}

Map<String, dynamic> _$HttpErrorToJson(HttpError instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'details': instance.details,
    };
