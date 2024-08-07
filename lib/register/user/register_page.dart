import 'package:flutter/material.dart';
import 'package:flutter_java_crud/register/user/service.dart';
import 'package:flutter_java_crud/register/user/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Service service = Service();
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  _fetchUsers() async {
    List<UserModel> fetchedUsers = await service.getAllUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Register User', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const Text('Name'),
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Name',
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Email'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Password'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState?.validate() ?? false) {
                      String response = await service.saveUser(
                          nameController.text,
                          emailController.text,
                          passwordController.text);
                      if (response.startsWith('Email already exists')) {
                        _showMessage(response);
                      } else {
                        _fetchUsers();
                        nameController.clear();
                        emailController.clear();
                        passwordController.clear();
                        _showMessage(response);
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20),
                const Text('Registered Users'),
                const SizedBox(height: 10),
                //         ListView.builder(
                //           shrinkWrap: true,
                //           physics: const NeverScrollableScrollPhysics(),
                //           itemCount: users.length,
                //           itemBuilder: (context, index) {
                //             return Container(
                // margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.grey),
                //   borderRadius: BorderRadius.circular(10.0),
                // ),
                //            child: ListTile(
                //               title: Text(users[index].name),
                //               subtitle: Text(users[index].email),
                //             ),);
                //           },
                //         ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
