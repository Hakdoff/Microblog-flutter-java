import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_java_crud/microblog/model/post_model.dart';
import 'package:flutter_java_crud/microblog/services/post_service.dart';
import 'package:flutter_java_crud/register/user/service.dart';
import 'package:flutter_java_crud/register/user/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController postController = TextEditingController();
  PostService postService = PostService();
  Service service = Service();
  List<PostModel> posts = [];
  List<UserModel> users = [];
  String? profilePictureUrl;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profilePictureBytes;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserPosts();
    _fetchUsers();
    _fetchProfilePicture();
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('userid $userId');
    return userId;
  }

  _fetchCurrentUserPosts() async {
    try {
      int? userId = await _getCurrentUserId();
      if (userId != null) {
        List<PostModel> fetchedPosts =
            await postService.getPostsByUserId(userId);
        setState(() {
          posts = fetchedPosts.where((post) => post.createdAt != null).toList()
            ..sort((a, b) => parseDateTime(b.createdAt)
                .compareTo(parseDateTime(a.createdAt)));
        });
        print('Posts fetched $posts');
      }
    } catch (e) {
      print("Error $e");
    }
  }

  _fetchUsers() async {
    try {
      List<UserModel> fetchedUsers = await service.getAllUsers();
      setState(() {
        users = fetchedUsers;
      });
      print("users $users");
    } catch (e) {
      print("Error $e");
    }
  }

  _fetchPosts() async {
    try {
      List<PostModel> fetchPosts = await postService.getallPosts();
      setState(() {
        posts = fetchPosts;
      });
      print('Posts fetched: $posts');
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  Future<void> _fetchProfilePicture() async {
    int? userId = await _getCurrentUserId();
    if (userId != null) {
      String? fetchedUrl = await postService.getProfilePicture(userId);
      setState(() {
        profilePictureUrl = fetchedUrl != null
            ? "http://localhost:8080/profilePictures/$userId"
            : null;
        print("Profile picture URL fetched: $profilePictureUrl");
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    int? userId = await _getCurrentUserId();
    if (userId != null) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List fileBytes = await pickedFile.readAsBytes();
        String? uploadedFilename = await postService.uploadProfilePicture(
            userId, fileBytes, pickedFile.name);
        if (uploadedFilename != null) {
          setState(() {
            profilePictureUrl =
                "http://localhost:8080/profilePictures/$uploadedFilename";
            _profilePictureBytes = fileBytes;
          });
          print("Profile picture updated $profilePictureUrl");
        } else {
          print("Error uploading");
        }
      } else {
        print("No file selected");
      }
    }
  }

  DateTime parseDateTime(String dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print("Error parsing date time: $e");
      return DateTime.now(); // Fallback
    }
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Column(
                  children: [
                    Center(
                      child: profilePictureUrl != null
                          ? _profilePictureBytes != null
                              ? Image.memory(
                                  _profilePictureBytes!,
                                  height: 200,
                                  width: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                )
                              : Image.network(
                                  profilePictureUrl!,
                                  height: 200,
                                  width: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                )
                          : const CircularProgressIndicator(), // Show a loading indicator while fetching
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed:
                          _uploadProfilePicture, // Function to upload new profile picture
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile Picture'),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: postController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Content',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some content';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() == true) {
                            int? userId = await _getCurrentUserId();
                            if (userId != null) {
                              await postService.createPost(
                                postController.text,
                                userId,
                              );
                              postController.clear();
                              _fetchPosts();
                            }
                          }
                        },
                        child: const Text('Post'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final user =
                        users.firstWhere((user) => user.id == post.userId);
                    String username = user.name;

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
                                Center(
                                  child: profilePictureUrl != null
                                      ? _profilePictureBytes != null
                                          ? Image.memory(
                                              _profilePictureBytes!,
                                              height: 30,
                                              width: 30,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                          : Image.network(
                                              profilePictureUrl!,
                                              height: 30,
                                              width: 30,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                      : const CircularProgressIndicator(), // Show a loading indicator while fetching
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
      ),
    );
  }
}
