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
              final String content = data['content'] ?? "N/A";
              final int createdAt = data['createdAt'] ?? -1;
              final String postId = posts[index].id;

              return ListTile(
                title: Text(author),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content),
                    Text(createdAt.toString()),
                    // 추가적인 Text 위젯을 필요에 따라 계속 추가할 수 있습니다.
                  ],
                ),
                onTap: () {
                  // ListTile이 클릭되었을 때 실행되는 코드
                  // Navigator.pushNamed(
                  //   context,
                  //   '/community/$postId', // post의 ID를 경로에 추가
                  // );
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
