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
      home: UserPostManager(),
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

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createPost() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'title': _titleController.text,
        'body': _bodyController.text,
        'userId': users.isNotEmpty ? users[0]['id'] : 1,
      }),
    );
    if (response.statusCode == 201) {
      final newPost = json.decode(response.body);
      setState(() {
        posts.add(newPost);
        _titleController.clear();
        _bodyController.clear();
      });
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<void> updatePost(int index) async {
    final post = posts[index];
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/${post['id']}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'id': post['id'],
        'title': _titleController.text,
        'body': _bodyController.text,
        'userId': post['userId'],
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        posts[index] = json.decode(response.body);
        _editingIndex = null;
        _titleController.clear();
        _bodyController.clear();
      });
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int index) async {
    final post = posts[index];
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/${post['id']}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        posts.removeAt(index);
      });
    } else {
      throw Exception('Failed to delete post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Post Manager')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _editingIndex == null ? createPost : () => updatePost(_editingIndex!),
              child: Text(_editingIndex == null ? 'Create Post' : 'Update Post'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(posts[index]['title']),
                    subtitle: Text(posts[index]['body']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
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