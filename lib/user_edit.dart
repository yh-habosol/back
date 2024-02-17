import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class UserEditPage extends StatefulWidget {
  const UserEditPage({Key? key}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  File? _imageFile;

  // 이미지를 갤러리에서 선택하는 함수
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      print("result: ${result!.names}");

      if (result.files.isNotEmpty) {
        setState(() async {
          print("is setState");
          List<int> fileBytes = result.files.single.bytes!;
          print("fileBytes: $fileBytes");

          // Get the temporary directory
          Directory tempDir = await getTemporaryDirectory();

          // Create a temporary file
          File tempFile = File(join(tempDir.path, 'temp_image'));

          // Write the bytes to the file
          await tempFile.writeAsBytes(fileBytes);

          // Now you can use the file as needed
          _imageFile = tempFile;
          print("imageFile : $_imageFile");
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // 이미지를 Firebase Storage에 업로드하고 URL을 가져오는 함수
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final Reference storageRef = storage
          .ref()
          .child('user_images/${FirebaseAuth.instance.currentUser!.uid}');
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Firebase Firestore의 user 문서 업데이트 함수
  Future<void> _updateUserProfile(String? imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'profile_image': imageUrl,
        });
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 표시 위젯
            _imageFile != null
                ? Image.file(_imageFile!)
                : const Text('No image selected'),

            // 갤러리에서 이미지 선택 버튼
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),

            // 이미지 업로드 및 프로필 업데이트 버튼
            ElevatedButton(
              onPressed: () async {
                if (_imageFile != null) {
                  final imageUrl = await _uploadImage(_imageFile!);
                  print("imageUrl: $imageUrl");
                  if (imageUrl != null) {
                    await _updateUserProfile(imageUrl);
                  }
                }
              },
              child: const Text('Upload and Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
