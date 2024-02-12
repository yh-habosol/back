import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;
  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

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

          final String author = data['author'] ?? "N/A";
          final String title = data['title'] ?? "N/A";
          final String content = data['content'] ?? "N/A";
          final DateTime createdAt =
              DateTime.fromMillisecondsSinceEpoch(data['createdAt']);
          final int numParticipate = data['numParticipate'] ?? -1;
          final int maxNumber = data['maxNumber'] ?? -1;
          final int numLike = data['numLike'] ?? -1;

          final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
          bool isCurrentUserAuthor = currentUserId == data['userId'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("author: $author"),
                Text("title: $title"),
                Text("content: $content"),
                Text("$numParticipate / $maxNumber"),
                Text(
                    "CreatedAt: ${createdAt.year} ${createdAt.month} ${createdAt.day}"),
                Text("numLike: $numLike"),
                if (isCurrentUserAuthor)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Edit 버튼 누를 때의 동작
                          Routemaster.of(context)
                              .push('/community/$postId/edit');
                        },
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Delete 버튼 누를 때의 동작
                          Routemaster.of(context)
                              .push('/community/$postId/delete');
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
