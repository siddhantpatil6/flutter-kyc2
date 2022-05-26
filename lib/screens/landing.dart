

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:flutter_shared_widgets/widgets/label.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/navigation_utils.dart';

import '../utils/action_handler.dart';

class LandingScreen extends StatelessWidget {
  final GetFlows flows;
  LandingScreen(this.flows);

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance?.addPostFrameCallback((timestamp) {
      debugPrint("==== POST BIND CALLBACK WORKEED 1=====");
      List<String> visitedScreens = flows.events.flows;
      if(visitedScreens.contains('email')){
        FormData().setValue(key: 'AutoPickedEmailHardCodeKey', value: 'true');
      }
      if(visitedScreens.length > 0){
        for(int i= 0;i<visitedScreens.length; i ++){
          if(i==0){
            NavigationUtils.popAndPushNamed(context: context,route:'/${visitedScreens.first}');
          }else{
            if(visitedScreens[i]=='bankUPI' && flows.events.data['imps']!=null && flows.events.data['imps'] && Platform.isAndroid ){
                NavigationUtils.pushNamed(context: context,route:'/upi_user_banklist');
            }else{
              NavigationUtils.pushNamed(context: context,route:'/${visitedScreens[i]}');
            }
            if(visitedScreens[i]==('selfie')){
              NavigationUtils.pushNamed(context: context,route:'/backNav_hypersnap_selfie');
            }
          }
        }
        WidgetActionHandler.lastUserState(flows.action.value.name , context);
        Navigator.pushNamed(context, '/${flows.action.value.name}');
      }else{
        WidgetActionHandler.lastUserState(flows.action.value.name , context);
        NavigationUtils.popAndPushNamed(context: context,route:'/${flows.action.value.name}');
      }
    });

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body:SafeArea(
          child:  Container(
            padding: EdgeInsets.all(24),
            child: Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Label(
                      title: 'Loading...',
                      textStyle: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                )
            ),
          ),
          ),
        );
  }
}