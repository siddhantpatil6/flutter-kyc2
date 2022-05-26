//  final configModel = configModelFromJson(jsonString);
// ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));
// String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
  ConfigModel(
      {required this.mobileNumber,
      required this.appsFlyerId,
      required this.cleverTapId,
      required this.appId,
      required this.envType,
      required this.releaseCode,
      required this.buildRelease,
      required this.appVersion,
      required this.ipAddress,
      required this.device,
      required this.pipeTopic,
      required this.language,
      required this.rneUrl,
      required this.tvcClientId,
      required this.guestToken,
      required this.macAddress,
      required this.platform,
      required this.source,
      required this.campaignName,
      required this.mediaSource,
      required this.channel,
      required this.uuid,
      required this.appName,
      });

  final String mobileNumber;
  final String appsFlyerId;
  final String cleverTapId;
  final String appId;
  final String envType;
  final String releaseCode;
  final String buildRelease;
  final String appVersion;
  final String ipAddress;
  final String device;
  final String pipeTopic;
  final String language;
  final String rneUrl;
  final String tvcClientId;
  final String guestToken;
  final String macAddress;
  final String platform;
  final String source;
  final String campaignName;
  final String mediaSource;
  final String channel;
  final String uuid;
  final String appName;

  factory ConfigModel.fromJson(Map<dynamic, dynamic> json) => ConfigModel(
        mobileNumber: json["mobileNumber"],
        appsFlyerId: json["appsFlyerId"],
        cleverTapId: json["cleverTapId"],
        appId: json["appId"],
        envType: json["envType"],
        releaseCode: json["releaseCode"],
        buildRelease: json["buildRelease"],
        appVersion: json["appVersion"],
        ipAddress: json["ipAddress"],
        device: json["device"],
        pipeTopic: json["pipeTopic"],
        language: json["language"],
        rneUrl: json["rneUrl"],
        tvcClientId: json["tvcClientId"],
        guestToken: json["guestToken"],
        macAddress: json["macAddress"],
        platform: json["platform"],
        source: json["source"],
        campaignName: json["campaignName"],
        mediaSource: json["mediaSource"],
        channel: json["channel"],
        uuid:json["uuid"],
        appName:json["appName"],
      );

  Map<dynamic, dynamic> toJson() => {
        "mobileNumber": mobileNumber,
        "appsFlyerId": appsFlyerId,
        "cleverTapId": cleverTapId,
        "appId": appId,
        "envType": envType,
        "release_code": releaseCode,
        "buildRelease": buildRelease,
        "appVersion": appVersion,
        "ipAddress": ipAddress,
        "device": device,
        "pipeTopic": pipeTopic,
        "language": language,
        "rneUrl": rneUrl,
        "tvcClientId": tvcClientId,
        "guestToken": guestToken,
        "macAddress": macAddress,
        "platform": platform,
        "source": source,
        "campaignName": campaignName,
        "mediaSource": mediaSource,
        "channel": channel,
        "uuid":uuid,
        "appName":appName
      };
}
