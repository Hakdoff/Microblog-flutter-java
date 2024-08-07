import 'package:flutter/material.dart';
import 'package:flutter_java_crud/microblog/model/post_model.dart';
import 'package:flutter_java_crud/microblog/services/post_service.dart';
import 'package:flutter_java_crud/register/user/service.dart';
import 'package:flutter_java_crud/register/user/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserPosts();
    _fetchUsers();
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: const Image(
                                    height: 30,
                                    width: 30,
                                    image: NetworkImage(
                                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                                  ),
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
