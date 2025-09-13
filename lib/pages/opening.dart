import 'package:chatapp/pages/login_screen.dart';
import 'package:chatapp/pages/sign_up_screen.dart';
import 'package:flutter/material.dart';

class Opening extends StatefulWidget {
  const Opening({super.key});

  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {

  bool flag=true;

  void togglePage(){
    setState(() {
      flag = !flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    if ( flag ){
      return LoginScreen(onTap: togglePage,);
    } else {
      return RegisterScreen(onTap: togglePage,);
    }
  }
}