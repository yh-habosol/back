import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routemaster/routemaster.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts Page"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('createdAt', descending: true)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          // 데이터를 가져와서 사용
          final List<DocumentSnapshot> posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data =
                  posts[index].data() as Map<String, dynamic>;

              final String author = data['author'] ?? "N/A";
              final String title = data['title'] ?? "N/A";
              final String content = data['content'] ?? "N/A";
              final DateTime createdAt =
                  DateTime.fromMillisecondsSinceEpoch(data['createdAt']);
              final int numParticipate = data['numParticipate'] ?? -1;
              final int maxNumber = data['maxNumber'] ?? -1;
              final String postId = posts[index].id;

              return ListTile(
                title: Text("author: $author"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("title: $title"),
                    Text("content: $content"),
                    Text("$numParticipate / $maxNumber"),
                    Text("CreatedAt: ${createdAt.toLocal()}"),
                  ],
                ),
                onTap: () {
                  Routemaster.of(context).push('/community/$postId');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Routemaster.of(context).push('/community/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
