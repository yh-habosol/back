import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routemaster/routemaster.dart';
import 'package:geolocator/geolocator.dart';

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
        title: const Text("create post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'content'),
            ),
            TextField(
              controller: maxNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'max number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // 포스트 작성 및 커뮤니티 페이지로 이동
                print("press button");
                await createPost();
                Routemaster.of(context).pop();
                // Routemaster.of(context).push('/community');
              },
              child: const Text('crate post'),
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
      // 현재 사용자 가져오기
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 사용자 정보 가져오기
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (userSnapshot.exists) {
          final String author = userSnapshot['name'] ?? 'N/A';
          // final Map<String, dynamic> location = userSnapshot['location'] ?? {};

          // 사용자의 현재 위치 가져오기
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          print("log: ${position.longitude}, lat: ${position.latitude}");
          final double logitude = position.longitude;
          final double latitude = position.latitude;

          // 포스트 Firestore에 추가
          final DocumentReference postRef =
              await FirebaseFirestore.instance.collection('Posts').add({
            'author': author,
            'title': title,
            'content': content,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'maxNumber': maxNumber,
            'location': {
              "lat": latitude,
              "log": logitude,
            },
            'userId': userSnapshot.id,
            'numParticipate': 1,
            'numLike': 0,
          });

          await postRef.collection('join_users').doc(currentUser.uid).set({
            'userId': currentUser.uid,
          });

          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .collection('join_challenges')
              .doc(postRef.id)
              .set({
            'postId': postRef.id,
            // 여기에 join_challenges와 관련된 추가 정보를 넣을 수 있습니다.
          });

          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userSnapshot.id)
              .collection('posts')
              .doc(postRef.id)
              .set({
            'postId': postRef.id,
            // 여기에 포스트와 관련된 추가 정보를 넣을 수 있습니다.
          });
        }
      }
    } else {
      // 유효성 검사 오류 처리
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('유효성 검사 오류'),
            content: const Text('모든 필드를 채워주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
