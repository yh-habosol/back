import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userData = {};
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext con, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Firebase App"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Welcome to Firebase App"),
                  ElevatedButton(
                    onPressed: () {
                      // /login으로 이동하는 버튼
                      Routemaster.of(context).push('/login');
                    },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // /join으로 이동하는 버튼
                      Routemaster.of(context).push('/signup');
                    },
                    child: const Text('Signup'),
                  ),
                ],
              ),
            ),
          );
        } else {
          final String userId = FirebaseAuth.instance.currentUser!.uid;
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
            body: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                // 데이터를 가져와서 사용
                userData = snapshot.data!.data() as Map<String, dynamic>;

                return Center(
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
                          Routemaster.of(context).push('/community');
                        },
                        child: const Text('Go to /posts'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Routemaster.of(context).push('/map');
                        },
                        child: const Text('Go to /map'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
