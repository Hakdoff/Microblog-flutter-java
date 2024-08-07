import 'package:flutter/material.dart';
import 'package:flutter_java_crud/microblog/pages/post.dart';
import 'package:flutter_java_crud/register/user/register_page.dart';
import 'package:flutter_java_crud/register/user/service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Email'),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 10),
            const Text('Password'),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  var response = await service.loginUser(
                    emailController.text,
                    passwordController.text,
                  );
                  if (response != "Login Failed") {
                    await service.saveToken(response);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MicroBlog()),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response)),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()));
                },
                child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
