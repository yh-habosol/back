import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase App")),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                submitButton(),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input your email address.',
        labelText: 'Email Address',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input your password.',
        labelText: 'Password',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          // 여기에 작성
          try {
            UserCredential authResult =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );

            // Firestore에 사용자 정보 추가
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(authResult.user!.uid)
                .set({
              // 'name', 'email', 등 사용자 정보를 추가할 수 있습니다.
              'email': _emailController.text,
              'name': _emailController.text.split('@')[0],
              'level': 1,
              'progress': 0,
              'profile_image': "",
              'exp': 0,
              'user_flower_counts': {
                'flower1': 0,
                'flower2': 0,
                'flower3': 0,
                'flower4': 0,
                'flower5': 0,
                'flower6': 0,
              },
              'user_waterdrop_counts': {
                'waterdrop1': 0,
                'waterdrop2': 0,
                'waterdrop3': 0,
                'waterdrop4': 0,
                'waterdrop5': 0,
                'waterdrop6': 0,
              },
            });

            // 등록 후 /로 이동
            Routemaster.of(context).push('/');
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              print('The account already exists for that email.');
            }
          } catch (e) {
            print(e.toString());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
