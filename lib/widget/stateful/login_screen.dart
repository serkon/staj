import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/model/user.dart';
import 'package:flutter_login/service/user_service.dart';
import 'package:flutter_login/util/encryption_provider.dart';
import 'package:flutter_login/widget/stateless/LbsText.dart';
import 'package:flutter_login/widget/stateless/expense_image_asset.dart';
import 'package:flutter_login/widget/stateless/give_message.dart';
import 'package:flutter_login/widget/stateless/login_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_login/widget/stateful/base/NotAuthenticatedScreenState.dart';
import 'employee_info_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginScreenState();
  }
}

class LoginScreenState extends NotAuthenticatedScreenState {
  String _usernameText, _passwordText;
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Future _doLogin() async {
    _usernameText = userNameController.text;
    _passwordText = passwordController.text;

    if (_usernameText == "" || _passwordText == "") {
      return giveMessage(context, "Cannot be empty");
    }

    final response = await UserService.loginUser(_usernameText, _passwordText);

    if (response.statusCode == 200) {
      giveMessage(context, "Success => " + (response.statusCode).toString());
    } else {
      return giveMessage(context, "Failure => " + (response.statusCode).toString());
    }

    final parsedJson = await json.decode(response.body);

    if (parsedJson['access_token'].toString()?.isEmpty ?? true) {
      return;
    }

    User user = User.fromJson(parsedJson);

    print("login screen");

    final globalStateManager = await SharedPreferences.getInstance();

    String encodedUser = json.encode(user);

    String encryptedUser = EncryptionProvider.encrypt(encodedUser);

    await globalStateManager.setString("currentUser", encryptedUser);

    debugPrint(user.tenantList.toString());

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => new EmployeeInfoScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(children: <Widget>[
            Background(),
        Center(
        child: SingleChildScrollView(
        child: Column(children: <Widget>[
    Padding(
    padding: EdgeInsets.only(top: 60),
    child: ExpenseImageAsset(),
    ),
    Text('JOURNEY',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white, fontWeight: FontWeight.w700)),
    Padding(
    padding: EdgeInsets.only(top:170, left:73, right: 72, bottom: 4),
    child: Text(
    'Your username and password are sent to you via e-mail',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600)),
    ),
    Padding(
    padding: EdgeInsets.only(top: 20),
    child:
    LbsText(fontSize: 16, title: "Username", icon: Icons.person, textCont: this.userNameController),
    ),
    Padding(
    padding: EdgeInsets.only(bottom: 20),
    child: LbsText(
    fontSize: 16,
    title: "Password",
    icon: Icons.lock,
    password: true,
    textCont: this.passwordController
    ),
    ),
    Container(
    padding: EdgeInsets.only(bottom: 30, top: 10),
    child: MaterialButton(
    onPressed: _doLogin,
    child: Text('login', style: TextStyle(color: Colors.black)),
    height: 40.0,
    minWidth: 315.0,
    color: Colors.white,
    shape: new RoundedRectangleBorder(
    borderRadius: new BorderRadius.circular(30.0))))
    ])))
    ]));
    }
  }