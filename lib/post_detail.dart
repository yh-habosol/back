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
  TextEditingController commentController = TextEditingController();

  final TextEditingController editCommentController = TextEditingController();

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
                Text("CreatedAt: ${createdAt.toLocal()}"),
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

                // 댓글 작성 부분
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Comments",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // 댓글 목록 출력
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, commentSnapshot) {
                          if (!commentSnapshot.hasData ||
                              commentSnapshot.data!.docs.isEmpty) {
                            return const Text('No comments yet.');
                          }

                          return Column(
                            children: commentSnapshot.data!.docs
                                .map((comment) => buildCommentItem(comment))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // 댓글 작성 폼
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                  labelText: 'Add a comment'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              // 댓글 작성 버튼 눌렀을 때의 동작
                              handlePostComment();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 댓글 아이템을 만드는 함수
  Widget buildCommentItem(QueryDocumentSnapshot comment) {
    final Map<String, dynamic> commentData =
        comment.data() as Map<String, dynamic>;

    final String commentAuthor = commentData['author'] ?? "Unknown";
    final String commentContent = commentData['content'] ?? "No content";
    final DateTime commentCreatedAt =
        DateTime.fromMillisecondsSinceEpoch(commentData['createdAt']);

    final String commentUserId = commentData['userId'] ?? ""; // 댓글의 userId 가져오기
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "autohr: $commentAuthor  createdAt: ${commentCreatedAt.toLocal()}"),
          Text("comment: $commentContent"),
          if (commentUserId == currentUserId)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Edit 버튼 누를 때의 동작
                    handleEditComment(comment.id, commentContent);
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    // Delete 버튼 누를 때의 동작
                    handleDeleteComment(comment.id);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
        ],
      ),
    );
  }

// Edit 댓글을 처리하는 함수
  void handleEditComment(String commentId, String currentContent) async {
    // 수정된 내용을 입력받는 다이얼로그 표시
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        editCommentController.text = currentContent; // 현재 내용으로 초기화
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextFormField(
            controller: editCommentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Edit your comment',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소 버튼 누를 때
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // 수정 내용을 다이얼로그에서 가져와 업데이트
                handleSaveEdit(commentId);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

// 수정된 내용을 저장하는 함수
  void handleSaveEdit(String commentId) async {
    final String editedContent = editCommentController.text.trim();

    if (editedContent.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'content': editedContent,
      });

      // 화면을 업데이트
      setState(() {});
      Navigator.pop(context); // 다이얼로그 닫기
    }
  }

// Delete 댓글을 처리하는 함수
  void handleDeleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // 댓글을 작성하는 함수
  void handlePostComment() async {
    final String commentContent = commentController.text.trim();

    if (commentContent.isNotEmpty) {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (userSnapshot.exists) {
          final String commentAuthor = userSnapshot['name'] ?? 'Unknown';

          // 현재 로그인한 사용자의 userID를 가져오기
          final String commentAuthorId = currentUser.uid;

          await FirebaseFirestore.instance
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .add({
            'author': commentAuthor,
            'userId': commentAuthorId, // userID 추가
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'content': commentContent,
          });

          // 댓글 작성 후 입력칸 초기화
          commentController.clear();
        }
      }
    }
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

      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .collection('join_users')
          .doc(currentUserId)
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

        await FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId)
            .collection('join_users')
            .doc(currentUserId)
            .set({
          'userId': currentUserId,
          // 여기에 join_users와 관련된 추가 정보를 넣을 수 있습니다.
        });
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
