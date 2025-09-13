import "package:flutter/material.dart";
import 'package:chatapp/repo/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key, required this.onTap});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;

  void signin(BuildContext context) async {
    final authrepo = AuthRepository();
    try {
      await authrepo.signInEmailPassword(_emailController.text,_passwordController.text,);
    } catch(e){
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign In",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        actions: [
          TextButton(
              onPressed: onTap,
              child: const Text(
                "Sign Up?",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(75.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 45,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Sign In",
                      style: TextStyle(fontSize: 45, color: Colors.black87)),
                  Icon(Icons.message, size: 60, color: Colors.black87)
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller:_emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    labelText: 'User Email',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade100, width: 3.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 5.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: const Icon(Icons.person_2_outlined,
                        color: Colors.purpleAccent),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade100, width: 3.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 5.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: const Icon(Icons.person_2_outlined,
                        color: Colors.purpleAccent),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              ElevatedButton(
                onPressed: () => signin(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300,50),
                  backgroundColor: Colors.purple.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
