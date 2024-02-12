import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/community.dart';
import 'package:practice/create_post.dart';
import 'package:practice/firebase_options.dart';
import 'package:practice/home.dart';
import 'package:practice/login.dart';
import 'package:practice/map.dart';
import 'package:practice/post_detail.dart';
import 'package:practice/signup.dart';
import 'package:routemaster/routemaster.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final routes = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomePage()),
  '/login': (route) => const MaterialPage(child: LoginPage()),
  '/signup': (route) => const MaterialPage(child: SignupPage()),
  '/community': (route) => const MaterialPage(child: PostsPage()),
  '/community/create': (route) => const MaterialPage(child: CreatePostPage()),
  '/community/:id': (route) => MaterialPage(
        child: CommunityDetailPage(postId: route.pathParameters['id']!),
      ),
  '/map': (route) => const MaterialPage(child: MapPage()),
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(routesBuilder: (contx) {
        return routes;
      }),
      title: "APP",
      debugShowCheckedModeBanner: false,
    );
  }
}
