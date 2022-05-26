import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/utils/device_asset_path.dart';
import 'package:http/http.dart' show get;
import 'package:kyc2/constants/api.dart';
import 'package:kyc2/utils/network_client.dart';
import 'package:path_provider/path_provider.dart';

class ImageAssetCacheHandler {
  static ImageAssetCacheHandler? _instance;
  ImageAssetCacheHandler._();
  static ImageAssetCacheHandler get instance =>
      _instance ??= ImageAssetCacheHandler._();

  static List<String> urlList = [];
  static List<String> localpathList = [];
  static List<String> svgListData = [
    'aadhar_back.svg',
    'aadhar_front.svg',
    'anual_income.svg',
    'Bank_Statment.svg',
    'cancelled_cheque.svg',
    'digilocker.svg',
    'email_bg.svg',
    'pan_card.svg',
    'signature.svg',
    'something_error.svg',
    'thank_you.svg',
    'upload.svg',
    'user_selfie.svg',
    'overlay_animation.svg'
  ];

  static List<String> png_gif_ListData = [
    /*'Aadhaar_back.gif',
    'Aadhaar_front.gif',
    'Bank_Statement.gif',
    'PAN.gif',
    'Cancelled_cheque.gif'*/
  ];

   void initData() {
    //_genetareURLdata();
     print('mylog --> initData ${AssetPath.asset_local_path} ');
     if(AssetPath.asset_local_path == null){
       _downloadAndWritetoFile();
     }else if(AssetPath.asset_local_path!.isNotEmpty &&  AssetPath.asset_local_path != null){
       var fileCount = Directory(AssetPath.asset_local_path ?? '/data/user/0/com.example.kyc2.host/app_flutter/images').listSync().length ;
       if(fileCount < (svgListData.length + png_gif_ListData.length) ){
         _downloadAndWritetoFile();
       }
     }else{
       _downloadAndWritetoFile();
     }

  }

  static void _genetareURLdata() {
    svgListData.forEach((element) {
      String url = '${appConfig[BASE_URL_CDN_KEY]}/icons/$element';
      //debugPrint('url in svg $url');
      urlList.add(url);
    });

    png_gif_ListData.forEach((element) {
      String url = '${appConfig[BASE_URL_CDN_KEY]}/images/$element';
      //debugPrint('url in others $url');
      urlList.add(url);
    });
  }

  static void _downloadAndWritetoFile() {
    AssetPath.isAllow = false;
    if(AssetPath.total_Count == 0){
      AssetPath.total_Count = AssetPath.total_Count + svgListData.length + png_gif_ListData.length;
    }
    svgListData.forEach((element) async {
      List subdata = element.toString().split('/');
      String idname = subdata.last;
      var client = NetworkClient(baseUrl: '${appConfig[BASE_URL_CDN_KEY]}/icons/');


      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = documentDirectory.path + "/images";
      var filePathAndName = documentDirectory.path + '/images/$idname';
      AssetPath.asset_local_path = firstPath;
      if(await File(filePathAndName).exists()){
        var exitCount = Directory(firstPath).listSync().length ;
        print('$filePathAndName is already exist');
        if(AssetPath.downloaded_Count  < exitCount ){
          AssetPath.downloaded_Count = AssetPath.downloaded_Count + 1;
          print('my log----> ${AssetPath.downloaded_Count } out of ${AssetPath.total_Count} downloaded');
        }
      }else{
        try{

          var response = await client.get(url: idname);
          print('my log -- > ${response.statusCode}');
          if(response.statusCode.toString() == '200' && !await File(filePathAndName).exists()){
            await Directory(firstPath).create(recursive: true);
            File file2 = File(filePathAndName);
            file2.writeAsBytesSync(response.bodyBytes);

            AssetPath.downloaded_Count = AssetPath.downloaded_Count + 1;

            debugPrint('updated file path is ${file2.path}');
            print('my log----> ${AssetPath.downloaded_Count } out of ${AssetPath.total_Count} downloaded');
          }

        } catch (e) {
          print(e);
          return null;
        }


      }
      //localpathList.add(file2.path);
    });

    png_gif_ListData.forEach((element) async {

      List subdata = element.toString().split('/');
      String idname = subdata.last;
      var client = NetworkClient(baseUrl: '${appConfig[BASE_URL_CDN_KEY]}/images/');

      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = documentDirectory.path + "/images";
      var filePathAndName = documentDirectory.path + '/images/$idname';

      AssetPath.asset_local_path = firstPath;
      if(await File(filePathAndName).exists()){
        print('$filePathAndName is already exist');
        var exitCount = Directory(firstPath).listSync().length ;
        if(AssetPath.downloaded_Count  < exitCount ){
          AssetPath.downloaded_Count = AssetPath.downloaded_Count + 1;
          print('my log----> ${AssetPath.downloaded_Count } out of ${AssetPath.total_Count} downloaded');
        }
      }else{
        try{
          var response = await client.get(url: idname);
          print('my log -- > ${response.statusCode}');
          if(response.statusCode.toString() == '200' && !await File(filePathAndName).exists()){
            await Directory(firstPath).create(recursive: true);
            File file2 = File(filePathAndName);
            file2.writeAsBytesSync(response.bodyBytes);

            AssetPath.downloaded_Count = AssetPath.downloaded_Count + 1;
            debugPrint('updated file path is ${file2.path}');
            print('my log----> ${AssetPath.downloaded_Count } out of ${AssetPath.total_Count} downloaded');
          }

        } catch (e) {
          print(e);
          return null;
        }


      }
      //localpathList.add(file2.path);
    });
    AssetPath.isAllow = true;
    //debugPrint('local path is $localpathList');
    //AssetPath.asset_local_path = localpathList;
  }
}
