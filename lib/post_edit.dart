import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routemaster/routemaster.dart';

class PostEditPage extends StatefulWidget {
  final String postId;
  const PostEditPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostEditPageState createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController maxNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Post not found');
          }

          final Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          final String title = data['title'] ?? "";
          final String content = data['content'] ?? "";
          final int maxNumber = data['maxNumber'] ?? -1;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController..text = title,
                  decoration: const InputDecoration(labelText: 'title'),
                ),
                TextField(
                  controller: contentController..text = content,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                TextField(
                  controller: maxNumberController..text = maxNumber.toString(),
                  decoration: const InputDecoration(labelText: 'maxNumber'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Save 버튼 누를 때의 동작
                    await saveChanges();
                    // /community 페이지로 리디렉션
                    Routemaster.of(context).replace('/community');
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> saveChanges() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();
    final int maxNumber = int.parse(maxNumberController.text.trim());

    if (content.isNotEmpty) {
      // 현재 사용자 가져오기
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 사용자 정보 가져오기
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (userSnapshot.exists) {
          // 수정된 내용을 Firestore의 Posts 컬렉션에 업데이트
          await FirebaseFirestore.instance
              .collection('Posts')
              .doc(widget.postId)
              .update({
            'title': title,
            'content': content,
            'maxNumber': maxNumber,
          });
        }
      }
    } else {
      // 유효성 검사 오류 처리
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
