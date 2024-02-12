import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routemaster/routemaster.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController maxNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            TextField(
              controller: maxNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum Number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Create post and navigate back to the community page
                await createPost();
                Routemaster.of(context).pop();
              },
              child: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createPost() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();
    final int maxNumber = int.tryParse(maxNumberController.text.trim()) ?? 0;

    if (title.isNotEmpty && content.isNotEmpty && maxNumber > 0) {
      // Add the post to Firestore
      await FirebaseFirestore.instance.collection('Posts').add({
        'author':
            'CurrentUser', // You may replace this with the actual author information
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'maxNumber': maxNumber,
      });
    } else {
      // Handle validation errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: const Text('Please fill in all fields with valid values.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
