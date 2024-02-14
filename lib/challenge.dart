import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<QueryDocumentSnapshot> randomChallenges = [];

  Future<void> _generateDailyChallenges() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final QuerySnapshot challengesSnapshot = await FirebaseFirestore
            .instance
            .collection('Challenges')
            .limit(5)
            .get();

        final CollectionReference dailyChallengesCollection = FirebaseFirestore
            .instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('daily_challenges');

        await dailyChallengesCollection.get().then((querySnapshot) {
          for (QueryDocumentSnapshot doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });

        for (final QueryDocumentSnapshot challengeDoc
            in challengesSnapshot.docs) {
          final String challengeId = challengeDoc.id;
          await dailyChallengesCollection.doc(challengeId).set({
            'challengeId': challengeId,
          });
        }

        setState(() {
          randomChallenges = challengesSnapshot.docs;
        });
      }
    } catch (e) {
      print('Error generating daily challenges: $e');
    }
  }

  void _scheduleDailyChallengesDeletion() {
    // Add logic to schedule daily challenges deletion if needed
    // This might involve using a background job or a periodic task
    // to run at 6 AM every day.
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
            const Text("Hello, World!"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _generateDailyChallenges();
                _scheduleDailyChallengesDeletion();
              },
              child: const Text('Generate Daily Challenges'),
            ),
            const SizedBox(height: 16),
            if (randomChallenges.isNotEmpty)
              Column(
                children: randomChallenges
                    .map((challengeDoc) => ListTile(
                          title: Text(
                            'Challenge: ${challengeDoc['challenge']}',
                          ),
                          onTap: () {
                            // 원하는 작업을 수행하도록 수정
                            // 여기서는 일단 팝업을 닫기만 함
                            // Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
