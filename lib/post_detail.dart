import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityDetailPage extends StatelessWidget {
  final String postId;
  const CommunityDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Detail"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Posts').doc(postId).get(),
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

          // postId에 해당하는 문서 데이터
          final Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Post ID: $postId"),
                Text("Author: ${data['author']}"),
                Text("Content: ${data['content']}"),
                // 추가적인 필드에 대한 정보를 출력할 수 있습니다.
              ],
            ),
          );
        },
      ),
    );
  }
}
