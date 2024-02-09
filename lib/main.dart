import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/firebase_options.dart';
import 'package:practice/home.dart';
import 'package:practice/login.dart';
import 'package:practice/signup.dart';

// Future<void> signUpAndSaveUserInfo(String email, String password) async {
//   try {
//     // 회원가입
//     UserCredential userCredential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     // Firestore에 사용자 정보 저장
//     await saveUserInfo(userCredential.user!);

//     print("User signed up and user info saved");
//   } catch (e) {
//     print("Error during sign-up: $e");
//   }
// }

// Future<void> saveUserInfo(User user) async {
//   try {
//     // Firestore의 'users' 컬렉션에 사용자 정보 추가
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'uid': user.uid,
//       'email': user.email,
//       // 추가로 필요한 사용자 정보는 여기에 추가할 수 있습니다.
//     });

//     print("User info saved to Firestore");
//   } catch (e) {
//     print("Error saving user info: $e");
//   }
// }

// Future<Map<String, dynamic>?> getUserInfo(String uid) async {
//   try {
//     // Firestore에서 사용자 정보 가져오기
//     DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();

//     // 사용자 정보가 존재하면 해당 정보를 반환, 없으면 null 반환
//     return documentSnapshot.exists ? documentSnapshot.data() : null;
//   } catch (e) {
//     print("Error getting user info: $e");
//     return null;
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               // 회원가입
//               await signUpAndSaveUserInfo('test@example.com', 'password');

//               // 사용자 정보 가져오기
//               String uid = FirebaseAuth.instance.currentUser!.uid;
//               Map<String, dynamic>? userInfo = await getUserInfo(uid);

//               // 사용자 정보 출력
//               print("User Info: $userInfo");
//             },
//             child: const Text('Sign Up and Get User Info'),
//           ),
//         ),
//       ),
//     );
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// 로그인, 회원가입 할 때 사용했던 코드
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}
//////

