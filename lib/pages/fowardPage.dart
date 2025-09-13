import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/components/message.dart';
import 'package:chatapp/pages/components/user_tile.dart';
import 'package:chatapp/repo/auth_repository.dart';
import 'package:chatapp/repo/chat_repository.dart';
import 'package:flutter/material.dart';

class ForwardPage extends StatelessWidget {
  final Map<String,dynamic> message;
  BuildContext context;
  ForwardPage({super.key,required this.message, required this.context});

  final authRepository = AuthRepository();
  final chatRepository = ChatRepository();

  void sendMessage(String clientID, String message, String fileUrl, String fileHash, List<String> fQueue) async {
      await chatRepository.forwardFile(clientID, message, fileUrl, fileHash, fQueue);
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Forward Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder(
        stream: chatRepository.getUsersStream(),
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

    Widget _userList(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != authRepository.getUser()!.email) {
      return UserTile(
        text: userData["user"],
        email: userData["email"],
        onTap: () {
          List<String> fQueue = ((message["fQueue"] as List<dynamic>?) ?? [])
              .map((e) => e.toString())
              .toList();

          sendMessage(
            userData["uid"],
            message["message"] ?? "", 
            message["file"] ?? "",   
            message["fileHash"] ?? "", 
            fQueue,
          );
          print(message);
        },
      );
    } else {
      return Container();
    }
  }

}
