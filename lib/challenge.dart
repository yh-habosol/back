import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<String> dailyChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadDailyChallenges();
  }

  Future<void> _loadDailyChallenges() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 현재 로그인한 사용자의 daily_challenges 컬렉션에서 문서들을 가져오기
        QuerySnapshot userChallengesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('daily_challenges')
            .get();
        print("is userChallenegspan? ${userChallengesSnapshot.docs}");
        if (userChallengesSnapshot.docs.isNotEmpty) {
          List<String> loadedChallenges = userChallengesSnapshot.docs
              .map((challengeDoc) => challengeDoc['challenge'] as String)
              .toList();

          setState(() {
            dailyChallenges = loadedChallenges;
          });
        }
      }
    } catch (e) {
      print('Error loading daily challenges: $e');
    }
  }

  Future<void> _generateRandomChallenges() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Challenges 컬렉션에서 랜덤으로 5개의 문서를 가져오기
        QuerySnapshot allChallengesSnapshot =
            await FirebaseFirestore.instance.collection('Challenges').get();

        List<QueryDocumentSnapshot> allChallenges = allChallengesSnapshot.docs;

// 랜덤으로 5개의 문서를 선택
        List<QueryDocumentSnapshot> randomChallenges = List.from(allChallenges)
          ..shuffle();

        if (randomChallenges.length > 5) {
          randomChallenges = randomChallenges.take(5).toList();
        }

        print("Random Challenges: ${randomChallenges.map((doc) => doc.id)}");

        List<String> newChallenges = randomChallenges
            .map((challengeDoc) => challengeDoc['challenge'] as String)
            .toList();
        print("newChallenge: $newChallenges");
        print("random? $newChallenges");

        await _deleteAndCreateUserChallenges(currentUser.uid, randomChallenges);

        setState(() {
          dailyChallenges = newChallenges;
        });
      }
    } catch (e) {
      print('Error generating random challenges: $e');
    }
  }

  Future<void> _deleteAndCreateUserChallenges(
      String userId, List<QueryDocumentSnapshot> randomChallenges) async {
    CollectionReference userChallengesCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('daily_challenges');
    print(randomChallenges.map((doc) => doc.id));
    // daily_challenges 컬렉션 삭제
    await userChallengesCollection.get().then((querySnapshot) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    // daily_challenges 컬렉션에 랜덤으로 선택된 challenge 문서들의 id 추가
    for (QueryDocumentSnapshot challengeDoc in randomChallenges) {
      await userChallengesCollection.add({
        'challenge': challengeDoc.id,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenge Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (dailyChallenges.isNotEmpty)
              Column(
                children: dailyChallenges
                    .map((challenge) => ListTile(
                          title: Text('Challenge: $challenge'),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateRandomChallenges,
              child: const Text('Daily Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
