import 'package:flutter/material.dart';

class UserHome extends StatelessWidget {
  UserHome({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Text("User Home")
        ),
      ),
    );
  }
}
