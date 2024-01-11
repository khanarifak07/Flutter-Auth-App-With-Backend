import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;

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
      body: const Center(
        child: Text("Welcome Profile"),
      ),
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
