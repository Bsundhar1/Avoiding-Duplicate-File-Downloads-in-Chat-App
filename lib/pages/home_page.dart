import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/components/user_tile.dart';
import 'package:chatapp/repo/auth_repository.dart';
import 'package:chatapp/repo/chat_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final authRepo = AuthRepository();
  final chatRepo = ChatRepository();

  void logout() {
    authRepo.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        actions: [
          TextButton(
              onPressed: logout,
              child: const Text(
                "Log Out",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))
        ],
      ),
      body: StreamBuilder(
        stream: chatRepo.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading");
          }

          return ListView(
            children: snapshot.data!.map<Widget>((userData)=> _userList(userData,context)).toList(),
          );
        },
      ),
    );
  }

  Widget _userList(Map<String, dynamic> userData, BuildContext context){
    if ( userData["email"] != authRepo.getUser()!.email){
      return UserTile(text: userData["user"],email: userData["email"],onTap: (){
      Navigator.push(context,MaterialPageRoute(builder: (context)=> ChatPage(user: userData["user"],email: userData["email"],clientID: userData["uid"],)));
    },);
    } else {
      return Container();
    }
  }
}
