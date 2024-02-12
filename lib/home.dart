import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice/login.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext con, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return const LoginPage();
        } else {
          userData = (ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?) ??
              {};

          return Scaffold(
            appBar: AppBar(
              title: const Text("Firebase App"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async => await FirebaseAuth.instance
                      .signOut()
                      .then((_) => Routemaster.of(context).push('/login')),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("login success"),
                  Text('User Name: ${userData['name'] ?? "N/A"}'),
                  Text('User Email: ${userData['email'] ?? "N/A"}'),
                  Text('User Level: ${userData['level'] ?? "N/A"}'),
                  Text('User Progress: ${userData['progress'] ?? "N/A"}'),
                  ElevatedButton(
                    onPressed: () {
                      // /posts로 이동하는 버튼
                      // Navigator.pushNamed(context, "/community");
                      Routemaster.of(context).push('/community');
                    },
                    child: const Text('Go to /posts'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // /posts로 이동하는 버튼
                      // Navigator.pushNamed(context, "/map");
                      Routemaster.of(context).push('/map');
                    },
                    child: const Text('Go to /map'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
