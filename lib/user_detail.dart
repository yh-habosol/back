import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth 인스턴스를 사용하여 현재 로그인한 사용자의 ID를 가져옵니다.
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // 사용자가 로그인하지 않았으면 로그인 페이지로 이동하거나 다른 처리를 수행할 수 있습니다.
      // 여기서는 로그인 페이지로 이동하는 예제 코드를 넣었습니다.
      // Navigator.pushReplacementNamed(context, '/login');
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Detail'),
        ),
        body: const Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    // FirebaseAuth를 사용하여 현재 사용자의 ID로 Firestore에서 문서를 가져옵니다.
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 아직 가져오지 못했을 때의 로딩 상태를 표시합니다.
          return Scaffold(
            appBar: AppBar(
              title: const Text('User Detail'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // 에러가 발생했을 때 에러 메시지를 표시합니다.
          return Scaffold(
            appBar: AppBar(
              title: const Text('User Detail'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // 데이터를 성공적으로 가져왔을 때의 UI를 표시합니다.
        var userData = snapshot.data?.data() as Map<String, dynamic>?;

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Detail'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User Name: ${userData?['name'] ?? "N/A"}'),
                Text('User Email: ${userData?['email'] ?? "N/A"}'),
                Text('User Level: ${userData?['level'] ?? "N/A"}'),
                // 나머지 사용자 정보에 대한 Text 위젯 추가

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Edit Profile 버튼을 눌렀을 때 /:userid/edit 페이지로 이동합니다.
                    Routemaster.of(context).push('/${user.uid}/edit');
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
