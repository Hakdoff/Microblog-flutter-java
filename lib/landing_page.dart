import 'package:flutter/material.dart';
import 'package:flutter_java_crud/microblog/pages/post.dart';
import 'package:flutter_java_crud/register/user/login_page.dart';
import 'package:flutter_java_crud/register/user/service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landing Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await service.logoutUser();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MicroBlog()));
              },
              child: const Text('Microblog')),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
