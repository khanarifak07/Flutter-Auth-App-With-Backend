import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController fullnameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  bool isLoading = false;
  File? avatar;
  File? coverImage;

  Future<void> pickAvatar() async {
    var pickedAvatar =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedAvatar != null) {
      setState(() {
        avatar = File(pickedAvatar.path);
      });
    }
  }

  Future<void> pickCoverImage() async {
    var pickedCoverImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedCoverImage != null) {
      setState(() {
        coverImage = File(pickedCoverImage.path);
      });
    }
  }

  Future<void> registerUser({
    required String username,
    required String password,
    required String email,
    required String fullname,
    required File avatar,
    File? coverImage,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      //create dio object
      Dio dio = Dio();
      //create Formdata object
      FormData formData = FormData.fromMap({
        "username": username,
        "email": email,
        "password": password,
        "fullname": fullname,
        "avatar": await MultipartFile.fromFile(avatar.path, filename: "avatar"),
        if (coverImage != null)
          "coverImage": await MultipartFile.fromFile(coverImage.path,
              filename: "coverImage")
      });
      //make dio post request
      Response response = await dio.post(register, data: formData);

      //handle the response
      if (response.statusCode == 200) {
        print("User registered successfully ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User registered successfully, ${response.data}")));
        Navigator.pushNamedAndRemoveUntil(
            context, "/todo-list", (route) => false);
      } else {
        print("User registration failed ${response.statusCode}");
      }
    } catch (e) {
      print("Error while registering user $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.red.shade200,
          title: const Text("User Registeration")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await pickAvatar();
              },
              child: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                radius: 50,
                backgroundImage: avatar != null
                    ? MemoryImage(avatar!.readAsBytesSync())
                    : null,
                child: avatar == null ? const Icon(Icons.add) : null,
              ),
            ),
            const Text("Avatar"),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                await pickCoverImage();
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10)),
                  height: 100,
                  width: double.maxFinite,
                  child: coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            coverImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.add)),
            ),
            const Text("Cover Image"),
            const SizedBox(height: 16),
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(
                hintText: "username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                hintText: "email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(
                hintText: "password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fullnameCtrl,
              decoration: const InputDecoration(
                hintText: "fullname",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            MaterialButton(
              minWidth: double.maxFinite,
              height: 50,
              color: Colors.red.shade200,
              onPressed: isLoading
                  ? null
                  : () async {
                      await registerUser(
                        username: usernameCtrl.text,
                        password: passwordCtrl.text,
                        email: emailCtrl.text,
                        fullname: fullnameCtrl.text,
                        avatar: avatar!,
                        coverImage: coverImage,
                      );
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
