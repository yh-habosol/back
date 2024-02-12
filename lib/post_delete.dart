import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class PostDeletePage extends StatefulWidget {
  final String postId;
  const PostDeletePage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDeletePageState createState() => _PostDeletePageState();
}

class _PostDeletePageState extends State<PostDeletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Post"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Are you sure you want to delete this post?"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 현재 로그인한 사용자의 ID 가져오기
                final String? currentUserId =
                    FirebaseAuth.instance.currentUser?.uid;

                // 1. Posts 컬렉션에서 해당 포스트 삭제
                await FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.postId)
                    .delete();

                // 2. Users 컬렉션에서 해당 사용자의 문서를 찾아서 해당 포스트 삭제
                if (currentUserId != null) {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(currentUserId)
                      .collection('posts')
                      .doc(widget.postId)
                      .delete();
                }

                // 3. /community 페이지로 리디렉션

                Routemaster.of(context).replace('/community');
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
