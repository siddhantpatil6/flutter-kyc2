import 'package:json_annotation/json_annotation.dart';
part 'http_error.g.dart';

@JsonSerializable()
class HttpError {
  final String code;
  final String message;
  final dynamic? details;

  HttpError({required this.code, required this.message, this.details});
  factory HttpError.fromJson(Map<String,dynamic> data) => _$HttpErrorFromJson(data);
  Map<String,dynamic> toJson() => _$HttpErrorToJson(this);
}