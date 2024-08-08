import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_java_crud/microblog/model/post_model.dart';
import 'package:flutter_java_crud/microblog/pages/profile.dart';
import 'package:flutter_java_crud/microblog/services/post_service.dart';
import 'package:flutter_java_crud/register/user/login_page.dart';
import 'package:flutter_java_crud/register/user/service.dart';
import 'package:flutter_java_crud/register/user/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class MicroBlog extends StatefulWidget {
  const MicroBlog({super.key});

  @override
  State<MicroBlog> createState() => _MicroBlogState();
}

class _MicroBlogState extends State<MicroBlog> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController postController = TextEditingController();
  PostService postService = PostService();
  Service service = Service();
  List<PostModel> posts = [];
  List<UserModel> users = [];
  Map<int, String?> profilePictureUrls = {};

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchUsers();
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('Retrieved User ID: $userId'); // Debug statement
    return userId;
  }

  _fetchPosts() async {
    try {
      List<PostModel> fetchPosts = await postService.getallPosts();
      setState(() {
        posts = fetchPosts.where((post) => post.createdAt != null).toList()
          ..sort((a, b) =>
              parseDateTime(b.createdAt).compareTo(parseDateTime(a.createdAt)));
      });
      print('Posts fetched: $posts');
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  _fetchUsers() async {
    try {
      List<UserModel> fetchedUsers = await service.getAllUsers();
      setState(() {
        users = fetchedUsers;
      });
      print('Users fetched: $users');
      await _fetchAllProfilePictures();
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> _fetchAllProfilePictures() async {
    for (var user in users) {
      String? fetchedUrl = await postService.getProfilePicture(user.id);
      setState(() {
        profilePictureUrls[user.id] = fetchedUrl != null
            ? "http://localhost:8080/profilePictures/${user.id}"
            : null; // Default image URL
      });
    }
  }

  DateTime parseDateTime(String dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return DateTime.now();
    }
    return DateTime.parse(dateTimeString);
  }

  void _showEditDialog(PostModel post) {
    TextEditingController editContoller =
        TextEditingController(text: post.content);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Edit post"),
              content: TextField(
                controller: editContoller,
                decoration:
                    const InputDecoration(hintText: 'Edit post content'),
                maxLines: 1,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    String response = await postService.updatePost(
                        post.id, editContoller.text);
                    Navigator.of(context).pop();
                    print(response);
                    _fetchPosts();
                  },
                )
              ]);
        });
  }

  void _deletePost(int postId) async {
    String response = await postService.deletePost(postId);
    print(response);
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microblog'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
                child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    accountName: Text('Erika'),
                    accountEmail: Text('asdad'))),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('userId');
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: userId)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await service.logoutUser();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextField(
                        controller: postController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Content',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState?.validate() == true) {
                            int? userId = await _getCurrentUserId();
                            if (userId != null) {
                              String response = await postService.createPost(
                                postController.text,
                                userId,
                              );
                              postController.clear();
                            }
                          }
                        },
                        child: const Text('Post'),
                      )
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final user =
                      users.firstWhere((user) => user.id == post.userId);
                  String username = user.name;
                  String? profilePicUrl = profilePictureUrls[post.userId];

                  DateTime createdAt = parseDateTime(post.createdAt);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.network(
                                profilePicUrl ??
                                    'http://localhost:8080/defaultProfilePic',
                                height: 30,
                                width: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      "Error loading image: $error"); // Debug statement
                                  return const Icon(Icons.error);
                                },
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  } else {
                                    print(
                                        "Loading image..."); // Debug statement
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(timeago.format(createdAt)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Edit') {
                                    _showEditDialog(post);
                                  } else if (value == 'Delete') {
                                    _deletePost(post.id);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'Edit', 'Delete'}
                                      .map((String choice) {
                                    return PopupMenuItem<String>(
                                        value: choice, child: Text(choice));
                                  }).toList();
                                },
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              post.content,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50.0),
                            child: Row(
                              children: [
                                Icon(Icons.thumb_up_sharp),
                                Spacer(),
                                Icon(Icons.comment),
                                Spacer(),
                                Icon(Icons.share_sharp),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
