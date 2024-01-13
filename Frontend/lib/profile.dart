import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/profile.model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isDataLoaded = false;
  ProfileModel? model;
  bool fieldEditing = false;
  bool isLoading = false;

  late TextEditingController usernameCtrl =
      TextEditingController(text: model!.username);
  late TextEditingController emailCtrl =
      TextEditingController(text: model!.email);
  late TextEditingController fullnameCtrl =
      TextEditingController(text: model!.fullname);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  //need to call this in init state so that avery time when user visits thsi page is automaticallly refreshed
  void getData() async {
    //get the user data from sharedpreferece
    var prefs = await SharedPreferences.getInstance();
    var user = prefs.getString("user");
    if (user != null) {
      model = ProfileModel.fromJson(user);
    }
    setState(() {
      isDataLoaded = true;
    });
  }

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

  Future<void> savedUpdatedUserData(ProfileModel model) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString('user', model.toJson());
    print(
        "Update user data saved successfully in shared preference ${model.toJson()}");
  }

  Future<void> updateUserProfile({
    String? username,
    String? email,
    String? fullname,
    File? avatar,
    File? coverImage,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });
      //get the saved token from shared preference
      var prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      //create dio instance
      Dio dio = Dio();
      //crea formdata instace as I need to pass images also else we can pass the normal body
      FormData formData = FormData.fromMap({
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (fullname != null) 'fullname': fullname,
        if (avatar != null) 'avatar': await MultipartFile.fromFile(avatar.path),
        if (coverImage != null)
          'coverImage': await MultipartFile.fromFile(coverImage.path),
      });

      //make dio patch request I alos need to pass the token as only logged in user can update the details
      Response response = await dio.patch(updateProfileDetailsApi,
          data: formData,
          options: Options(headers: {"Authorization": "Bearer $token"}));

      //handle the response
      if (response.statusCode == 200) {
        print("User profile updated successfully ${response.data}");
        //now I have saved user data in shared preference I need to remove that data and again saved the updated user data
        var prefs = await SharedPreferences.getInstance();
        prefs.remove('user');
        //now save the updated user data
        final updatedUser = ProfileModel.fromMap(response.data['data']);
        savedUpdatedUserData(updatedUser);
        //now again call the get data methods as we need to show the updated data
        getData();
      }
    } catch (e) {
      print("Error while updating user profile $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logoutUser() async {
    try {
      //get the accesstoken from share pref
      var prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      //create dio isntace
      Dio dio = Dio();

      //make dio post request
      Response response = await dio.post(logout,
          options: Options(headers: {"Authorization": "Bearer $token"}));

      //handle the response
      if (response.statusCode == 200) {
        print('Logged out successfully ${response.data}');
      } else {
        print("logout failed ${response.statusCode}");
      }
    } catch (e) {
      print("Error while logout $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('My profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/change-password");
            },
            child: const Text("Change Password"),
          )
        ],
      ),
      body: model != null
          ? Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await pickAvatar();
                    },
                    child: avatar != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                MemoryImage(avatar!.readAsBytesSync()))
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              model!.avatar,
                            ),
                          ),
                  ),
                  const Text("Avatar"),
                  const SizedBox(height: 16),
                  GestureDetector(
                      onTap: () async {
                        await pickCoverImage();
                      },
                      child: coverImage != null
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.red.shade200,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 100,
                              width: double.maxFinite,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  coverImage!,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          : model?.coverImage != null &&
                                  model!.coverImage.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 100,
                                  width: double.maxFinite,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      model!.coverImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 100,
                                  width: double.maxFinite,
                                  child: const Center(
                                    child: Text(
                                        "No cover image found tap to add cover image"),
                                  ),
                                )),
                  const Text("Cover Image"),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            fieldEditing = !fieldEditing;
                          });
                        },
                        child: const Text("Edit Fields")),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    enabled: fieldEditing,
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: fieldEditing,
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: fieldEditing,
                    controller: fullnameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Fullname",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    minWidth: 200,
                    height: 50,
                    color: Colors.red.shade200,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await updateUserProfile(
                              username: usernameCtrl.text,
                              email: emailCtrl.text,
                              fullname: fullnameCtrl.text,
                              avatar: avatar,
                              coverImage: coverImage,
                            );

                            setState(() {
                              fieldEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Profile details updated successfully")));
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Update"),
                  )
                ],
              ),
            )
          : isDataLoaded
              ? const Center(
                  child: Text("Something went wrong while fetching user data"))
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton: MaterialButton(
        color: Colors.red.shade200,
        onPressed: () async {
          await logoutUser();
          //remove the saved access tokne
          var pref = await SharedPreferences.getInstance();
          pref.remove("accessToken");
          var prefs = await SharedPreferences.getInstance();
          final token = pref.getString("accessToken");
          print("Access token after logout: $token");
          Navigator.pushNamedAndRemoveUntil(
              context, "/login", (route) => false);
        },
        child: const Text("Logout"),
      ),
    );
  }
}
