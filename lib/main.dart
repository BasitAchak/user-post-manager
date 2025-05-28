import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User and Post Manager',
      home: UserPostManager(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserPostManager extends StatefulWidget {
  @override
  _UserPostManagerState createState() => _UserPostManagerState();
}

class _UserPostManagerState extends State<UserPostManager> {
  List<dynamic> users = [];
  List<Map<String, dynamic>> posts = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ✅ 1. FETCH USERS
  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  // ✅ 2. CREATE POST (local only)
  void createPost() {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': _titleController.text,
      'body': _bodyController.text,
      'userId': users.isNotEmpty ? users[0]['id'] : 1,
    };

    setState(() {
      posts.add(newPost);
      _titleController.clear();
      _bodyController.clear();
    });
  }

  // ✅ 3. UPDATE POST (local only)
  void updatePost(int index) {
    setState(() {
      posts[index]['title'] = _titleController.text;
      posts[index]['body'] = _bodyController.text;
      _editingIndex = null;
      _titleController.clear();
      _bodyController.clear();
    });
  }

  // ✅ 4. DELETE POST (local only)
  void deletePost(int index) {
    setState(() {
      posts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User and Post Manager')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ User List Display
            Text('Users from JSONPlaceholder:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            users.isEmpty
                ? Text('Loading users...')
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(users[index]['name'], style: TextStyle(fontSize: 12)),
                              Text(users[index]['email'], style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            SizedBox(height: 20),

            // ✅ Form for Title and Body
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Post Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Post Body'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _editingIndex == null
                  ? createPost
                  : () => updatePost(_editingIndex!),
              child: Text(_editingIndex == null ? 'Create Post' : 'Update Post'),
            ),

            SizedBox(height: 20),

            // ✅ List of Created Posts
            Expanded(
              child: posts.isEmpty
                  ? Center(child: Text('No posts created yet.'))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(posts[index]['title']),
                            subtitle: Text(posts[index]['body']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    setState(() {
                                      _editingIndex = index;
                                      _titleController.text = posts[index]['title'];
                                      _bodyController.text = posts[index]['body'];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deletePost(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
