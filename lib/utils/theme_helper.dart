
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeHelper {
  static getTextTheme(BuildContext context, String? name){
    switch(name){
      case 'headline1':
        return Theme.of(context).textTheme.headline1;
      case 'headline2':
        return Theme.of(context).textTheme.headline2;
      case 'headline3':
        return Theme.of(context).textTheme.headline3;
      case 'headline4':
        return Theme.of(context).textTheme.headline4;
      case 'headline5':
        return Theme.of(context).textTheme.headline5;
      case 'headline6':
        return Theme.of(context).textTheme.headline6;
      case 'bodyText1':
      return Theme.of(context).textTheme.bodyText1;
      case 'bodyText2':
        return Theme.of(context).textTheme.bodyText2;
      default:
        return Theme.of(context).textTheme.bodyText1;
    }
  }
}