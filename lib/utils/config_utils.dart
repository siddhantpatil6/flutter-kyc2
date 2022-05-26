import 'package:kyc2/models/config_model.dart';
// Utils datas from native side
class ConfigSingleTon {

  static ConfigSingleTon? _instanceVariable;
  ConfigModel? configData;
  ConfigSingleTon._private();

  static ConfigSingleTon get instance =>
      _instanceVariable ??= ConfigSingleTon._private();

}