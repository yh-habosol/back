import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice/login.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext con, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return const LoginPage();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Firebase App"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async => await FirebaseAuth.instance
                      .signOut()
                      .then((_) => Navigator.pushNamed(context, "/login")),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  Text('User Name: ${userData['name']}'),
                  Text('User Pw: ${userData['password']}')
                ],
              ),
            ),
          );
        }
      },
    );
  }
}


// body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('User Name: ${userData['name']}'),
//             Text('User Email: ${userData['email']}'),
//             // 여기에 다른 사용자 정보를 표시하는 위젯들을 추가할 수 있습니다.
//           ],
//         ),
//       ),