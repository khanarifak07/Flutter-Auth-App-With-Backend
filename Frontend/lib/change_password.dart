import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });
      //get the token from share pref
      var pref = await SharedPreferences.getInstance();
      final String? token = pref.getString("accessToken");

      //create dio isntance
      Dio dio = Dio();
      //no need to create formdata instance as we are not sending data with images

      var passData = {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };
      //make dio pathc request
      Response response = await dio.patch(changeCurrentPassword,
          data: passData,
          options: Options(headers: {"Authorization": "Bearer $token"}));

      //handle the responser
      if (response.statusCode == 200) {
        print("Password changes successfullu ${response.data}");
      } else {
        print("Somehting wrong while chagneig password ${response.statusCode}");
      }
    } catch (e) {
      print("Password Changed Failed $e");
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
        title: const Text('Change Password'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: oldPassword,
              decoration: const InputDecoration(
                hintText: "old password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassword,
              decoration: const InputDecoration(
                hintText: "new password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassword,
              decoration: const InputDecoration(
                hintText: "confirm password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 35),
            MaterialButton(
              color: Colors.red.shade100,
              onPressed: () async {
                await changePassword(
                  oldPassword: oldPassword.text,
                  newPassword: newPassword.text,
                  confirmPassword: confirmPassword.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Password Changed successfully")));
                oldPassword.clear();
                newPassword.clear();
                confirmPassword.clear();
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
