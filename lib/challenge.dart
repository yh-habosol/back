import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<String> dailyChallenges = [];
  List<bool> challengeCheckboxes = [];
  List<String> challengeIds = [];

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
        print("isEmpty? $userChallengesSnapshot");
        if (userChallengesSnapshot.docs.isNotEmpty) {
          List<String> loadedChallenges = userChallengesSnapshot.docs
              .map((challengeDoc) => challengeDoc['challengeId'] as String)
              .toList();

          List<String> loadedChallengeIds = userChallengesSnapshot.docs
              .map((challengeDoc) => challengeDoc.id)
              .toList();

          setState(() {
            dailyChallenges = loadedChallenges;
            // challengeCheckboxes =
            //     List.generate(dailyChallenges.length, (index) => false);
            challengeIds = loadedChallengeIds;
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

        List<String> newChallenges =
            randomChallenges.map((challengeDoc) => challengeDoc.id).toList();

        print("newChallenges: $newChallenges");

        await _deleteAndCreateUserChallenges(currentUser.uid, randomChallenges);

        setState(() {
          dailyChallenges = newChallenges;
          // challengeCheckboxes =
          //     List.generate(dailyChallenges.length, (index) => false);
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

    // daily_challenges 컬렉션 삭제
    await userChallengesCollection.get().then((querySnapshot) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    // daily_challenges 컬렉션에 랜덤으로 선택된 challenge 문서들의 id 추가
    for (QueryDocumentSnapshot challengeDoc in randomChallenges) {
      await userChallengesCollection.add({
        'challengeId': challengeDoc.id,
      });
    }
  }

  Future<void> _completeChallenge(String challengeId) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 사용자의 done_challenges 컬렉션에 현시점 년도:에 해당 challenge id 저장
        String currentYear = DateTime.now().year.toString();
        String currentMonth = DateTime.now().month.toString();

        CollectionReference doneChallengesCollection = FirebaseFirestore
            .instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('done_challenges')
            .doc(currentYear)
            .collection(currentMonth);

        int index = challengeIds.indexOf(challengeId);

        DocumentReference docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('daily_challenges')
            .doc(challengeIds[index]);

        DocumentSnapshot docSnapshot = await docRef.get();

        dynamic fieldValue = docSnapshot['challengeId'];

        // 체크박스가 체크된 문서의 challengeId를 저장
        await doneChallengesCollection.add({
          'challengeId': fieldValue,
        });

        // 사용자의 exp를 1 증가
        int userExp = await _getUserExp(currentUser.uid);
        await _updateUserExp(currentUser.uid, userExp + 1);

        // 사용자의 exp가 10 이상이면 level을 1 증가하고 exp 초기화
        if (userExp + 1 >= 10) {
          await _increaseUserLevel(currentUser.uid);
          await _updateUserExp(currentUser.uid, 0);
        }
      }
    } catch (e) {
      print('Error completing challenge: $e');
    }
  }

  Future<int> _getUserExp(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      return userSnapshot['exp'] ?? 0;
    } catch (e) {
      print('Error getting user exp: $e');
      return 0;
    }
  }

  Future<void> _updateUserExp(String userId, int exp) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'exp': exp});
    } catch (e) {
      print('Error updating user exp: $e');
    }
  }

  Future<void> _increaseUserLevel(String userId) async {
    try {
      // 1. Increase user's level
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'level': FieldValue.increment(1)});

      // 2. Get a random waterdrop key (waterdrop1 ~ waterdrop6)
      List<String> waterdropKeys = [
        'waterdrop1',
        'waterdrop2',
        'waterdrop3',
        'waterdrop4',
        'waterdrop5',
        'waterdrop6'
      ];
      String randomWaterdropKey =
          waterdropKeys[Random().nextInt(waterdropKeys.length)];

      // 3. Increment the selected waterdrop count
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'user_waterdrop_counts.$randomWaterdropKey': FieldValue.increment(1),
      });
    } catch (e) {
      print(
          'Error increasing user level and incrementing random waterdrop: $e');
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
                children: List.generate(dailyChallenges.length, (index) {
                  String challenge = dailyChallenges[index];
                  return ListTile(
                    title: Row(
                      children: [
                        // Checkbox(
                        //   value: challengeCheckboxes[index],
                        //   onChanged: (value) {
                        //     setState(() {
                        //       challengeCheckboxes[index] = value!;
                        //       if (value) {
                        //         _completeChallenge(challengeIds[index]);
                        //       }
                        //     });
                        //   },
                        // ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('Challenges')
                              .doc(challenge)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              print("id?: ${snapshot.data!.id}");
                              return Text(
                                'Challenge: ${snapshot.data!['challenge']}',
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                      ],
                    ),
                  );
                }),
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
