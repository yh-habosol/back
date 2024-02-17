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
                      Text('User Exp: ${userData['exp'] ?? "N/A"}'),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower1 button click
                          // You can implement the logic here, such as incrementing the count
                        },
                        child: Text(
                            'flower1 Count: ${userData['user_flower_counts']['flower1'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower2 button click
                        },
                        child: Text(
                            'Flower2 Count: ${userData['user_flower_counts']['flower2'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower2 button click
                        },
                        child: Text(
                            'flower3 Count: ${userData['user_flower_counts']['flower3'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower2 button click
                        },
                        child: Text(
                            'flower4 Count: ${userData['user_flower_counts']['flower4'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower2 button click
                        },
                        child: Text(
                            'flower5 Count: ${userData['user_flower_counts']['flower5'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Flower2 button click
                        },
                        child: Text(
                            'flower6 Count: ${userData['user_flower_counts']['flower6'] ?? "N/A"}'),
                      ),
                      // Repeat the same pattern for Flower3, Flower4, ..., Flower6
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                          int waterdrop1Count =
                              userData['user_waterdrop_counts']['waterdrop1'] ??
                                  0;
                          if (waterdrop1Count > 0) {
                            // Increment flower1 count by waterdrop1 count
                            int flower1Count =
                                userData['user_flower_counts']['flower1'] ?? 0;
                            flower1Count += waterdrop1Count;

                            // Update user_flower_counts and user_waterdrop_counts
                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(userId)
                                .update({
                              'user_flower_counts.flower1': flower1Count,
                              'user_waterdrop_counts.waterdrop1': 0,
                            });
                            setState(() {
                              userData['user_flower_counts']['flower1'] =
                                  flower1Count;
                              userData['user_waterdrop_counts']['waterdrop1'] =
                                  0;
                            });
                          }
                        },
                        child: Text(
                            'Waterdrop1 Count: ${userData['user_waterdrop_counts']['waterdrop1'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                        },
                        child: Text(
                            'waterdrop2 Count: ${userData['user_waterdrop_counts']['waterdrop2'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                        },
                        child: Text(
                            'waterdrop3 Count: ${userData['user_waterdrop_counts']['waterdrop3'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                        },
                        child: Text(
                            'waterdrop4 Count: ${userData['user_waterdrop_counts']['waterdrop4'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                        },
                        child: Text(
                            'waterdrop5 Count: ${userData['user_waterdrop_counts']['waterdrop5'] ?? "N/A"}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle waterdrop1 button click
                        },
                        child: Text(
                            'waterdrop6 Count: ${userData['user_waterdrop_counts']['waterdrop6'] ?? "N/A"}'),
                      ),
                      // Repeat the same pattern for waterdrop2, waterdrop3, ..., waterdrop6
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
                      ElevatedButton(
                        onPressed: () {
                          Routemaster.of(context).push('/challenge');
                        },
                        child: const Text('Go to /challenge'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Routemaster.of(context).push('/$userId');
                        },
                        child: const Text("Go to User Detail"),
                      ),
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
                      ElevatedButton(
                        onPressed: () {
                          Routemaster.of(context).push('/challenge');
                        },
                        child: const Text('Go to /challenge'),
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
