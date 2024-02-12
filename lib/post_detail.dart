import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routemaster/routemaster.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int numLike;
  late bool isLiked;
  late int numParticipate;
  late int maxNumber;
  late bool isParticipating;
  late bool isCurrentUserAuthor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Detail"),
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

          final String author = data['author'] ?? "N/A";
          final String title = data['title'] ?? "N/A";
          final String content = data['content'] ?? "N/A";
          final DateTime createdAt =
              DateTime.fromMillisecondsSinceEpoch(data['createdAt']);

          // 변경: 참여 상태 및 수를 Firestore에서 가져옴
          maxNumber = data['maxNumber'] ?? -1;
          numParticipate = data['numParticipate'] ?? 0;
          isParticipating = (data['participants'] ?? [])
              .contains(FirebaseAuth.instance.currentUser?.uid);

          // 변경: 좋아요 상태 및 수를 Firestore에서 가져옴
          numLike = data['numLike'] ?? 0;
          isLiked = (data['likedBy'] ?? [])
              .contains(FirebaseAuth.instance.currentUser?.uid);

          final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
          isCurrentUserAuthor = currentUserId == data['userId'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("author: $author"),
                Text("title: $title"),
                Text("content: $content"),
                Text("Current Participants: $numParticipate / $maxNumber"),
                Text(
                    "CreatedAt: ${createdAt.year} ${createdAt.month} ${createdAt.day}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 변경: 참여 가능한 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 변경: 참여 버튼을 누를 때의 동작
                        handleJoinButton();
                      },
                      child: Text(isParticipating ? 'Disjoin' : 'Join'),
                    ),
                    // 변경: 좋아요 기능 추가
                    IconButton(
                      icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border),
                      color: isLiked ? Colors.red : null,
                      onPressed: () {
                        // 변경: 토글 버튼을 누를 때의 동작
                        handleLikeButton();
                      },
                    ),
                    // 변경: 좋아요 수 표시
                    Text("Likes: $numLike"),
                  ],
                ),
                if (isCurrentUserAuthor)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Edit 버튼 누를 때의 동작
                          Routemaster.of(context)
                              .push('/community/${widget.postId}/edit');
                        },
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Delete 버튼 누를 때의 동작
                          Routemaster.of(context)
                              .push('/community/${widget.postId}/delete');
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

  void handleJoinButton() async {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (isCurrentUserAuthor) {
      // 변경: 만약 현재 사용자가 글 작성자라면, 해당 팝업 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('You are the Creator'),
            content: const Text('You are the creator of this post.'),
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
      return;
    }

    if (isParticipating) {
      numParticipate--;
      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .update({
        'numParticipate': numParticipate,
        'participants':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.uid]),
      });

      // 변경: 사용자의 join_challenges 컬렉션에서 post ID 제거
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('join_challenges')
          .doc(widget.postId)
          .delete();
    } else {
      if (numParticipate < maxNumber) {
        numParticipate++;
        await FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId)
            .update({
          'numParticipate': numParticipate,
          'participants':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
        });

        // 변경: 사용자의 join_challenges 컬렉션에 post ID 추가
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .collection('join_challenges')
            .doc(widget.postId)
            .set({});
      } else {
        // 변경: 인원이 다 찼을 때 팝업 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Maximum Participants Reached'),
              content: const Text(
                  'The maximum number of participants has been reached.'),
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
        return; // 변경: 인원이 다 찼을 때 더 이상 코드 진행하지 않도록 리턴
      }
    }

    // 변경: 참여 상태 업데이트
    setState(() {
      isParticipating = !isParticipating;
    });
  }

  void handleLikeButton() async {
    // 변경: 토글하고 좋아요 상태 및 수 업데이트
    if (isLiked) {
      numLike--;
      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .update({
        'numLike': numLike,
        'likedBy':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.uid]),
      });
    } else {
      numLike++;
      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .update({
        'numLike': numLike,
        'likedBy':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
      });
    }

    // 변경: 좋아요 상태 업데이트
    setState(() {
      isLiked = !isLiked;
    });
  }
}
