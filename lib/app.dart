import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/opening.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if (snapshot.hasData){
          return HomePage();
        } else {
          return const Opening();
        }
      }),
    );
  }
}