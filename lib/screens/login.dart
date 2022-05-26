import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/widgets/custom_button.dart';
import 'package:flutter_shared_widgets/widgets/input_text.dart';
import 'package:kyc2/utils/network_client.dart';
import 'package:kyc2/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:kyc2/utils/from_data.dart';


class LoginScreen extends StatelessWidget {
  TextEditingController mobileNo = new TextEditingController();

  doLogin(BuildContext context) async {
    debugPrint("logging you in using mobile : "+ mobileNo.text);

    NetworkClient networkClient = new NetworkClient(baseUrl: 'http://kyc2-services-dev-1098000510.ap-south-1.elb.amazonaws.com');
    var result = await networkClient.post(url: '/internal/token', body: {
      "country_code": "+91",
      "mob_no": mobileNo.text,
      "user_id": "naruto",
      "source": "spark",
      "app_id": "naruto",
    }.toString());

    var token = jsonDecode(result.body)['token'];
    debugPrint("RESULT FOUND $token ====");

    Provider.of<FormData>(context, listen: false).setValue(key: 'token', value:token.toString());
    Navigator.of(context).pushNamed('/register');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: KycAppBar(title:'Login', screenId: 'login-screen'),
        body: SafeArea(
          child: Container(
            child: Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child:Form(
                    child: Column(
                      children: [
                        Padding(
                          padding:EdgeInsets.all(
                            0
                          ),
                          child: InputField(
                            title: 'Enter Mobile number',
                            hint: 'Enter Mobile number',
                            keyboardType: InputFieldKeyboardtype.number,
                            controller: mobileNo,
                            onChange: (value){

                            },
                          ),
                        ),
                        Padding(
                            padding:EdgeInsets.only(
                              top: 60,
                            ),
                            child:CustomButton(
                              title:'Login',
                              isLoadType:false,
                              onPressed: (){
                                  doLogin(context);
                            },
                              isLoading :false,
                            )
                        ),
                      ],
                    )
                  )
              ),
            ),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        )
    );
  }

}