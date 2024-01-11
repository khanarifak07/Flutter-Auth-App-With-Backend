import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/profile.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late TextEditingController usernameCtrl =
      TextEditingController(text: model!.username);
  late TextEditingController emailCtrl =
      TextEditingController(text: model!.email);
  late TextEditingController fullnameCtrl =
      TextEditingController(text: model!.fullname);

  ProfileModel? model;
  bool isLoading = false;
  bool isDataLoaded = false;
  bool isEditing = false;
  File? avatar;
  File? coverImage;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      //get the user data form share preference
      SharedPreferences pref = await SharedPreferences.getInstance();
      final String? user = pref.getString('user');
      if (user != null) {
        model = ProfileModel.fromJson(user);
      }
      setState(() {
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error while getting user data $e");
    }
  }

  Future<void> logoutUser() async {
    try {
      setState(() {
        isLoading = true;
      });
      //get the accessToken to verify adn logout user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("accessToken");
//create dio instance
      Dio dio = Dio();
      //we dont have to send any data so we are not creating formData
      //make dio post request
      Response response = await dio.post(logout,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      //handle the response
      if (response.statusCode == 200) {
        print("User logged out successfully ${response.data}");
        //remove the saved access token
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      } else {
        print("Error while logout user ");
      }
    } catch (e) {
      print("Error while logout user $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.red.shade200, title: const Text("Profile")),
      body: model != null
          ? Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(model!.avatar),
                  ),
                  const SizedBox(height: 10),
                  const Text("Avatar"),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                        height: 100,
                        width: double.maxFinite,
                        child: model?.coverImage != null &&
                                model!.coverImage.isNotEmpty
                            ? Image.network(
                                model!.coverImage,
                                fit: BoxFit.cover,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 100,
                                  width: double.maxFinite,
                                  color: Colors.red.shade200,
                                ),
                              )),
                  ),
                  const SizedBox(height: 10),
                  const Text("Cover Image"),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                        child: const Text("Edit Fields")),
                  ),
                  TextField(
                    enabled: isEditing,
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      hintText: "username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: isEditing,
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      hintText: "email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: isEditing,
                    controller: fullnameCtrl,
                    decoration: const InputDecoration(
                      hintText: "fullname",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    onPressed: () {},
                    minWidth: double.maxFinite,
                    height: 50,
                    color: Colors.red.shade200,
                    child: const Text("Update"),
                  )
                ],
              ),
            )
          : isDataLoaded
              ? const Text("Something went wrong while fetching user data")
              : const CircularProgressIndicator(),
      floatingActionButton: MaterialButton(
        color: Colors.red.shade200,
        onPressed: isLoading
            ? null
            : () async {
                await logoutUser();
                //remove the saved access token
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('accessToken');
                //check for access token
                SharedPreferences prefss =
                    await SharedPreferences.getInstance();
                final String? token = prefss.getString('accessToken');
                print("Access Token after logout : $token");
              },
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text("Logout"),
      ),
    );
  }
}
