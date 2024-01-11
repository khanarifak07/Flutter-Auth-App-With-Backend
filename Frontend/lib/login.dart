import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/profile.model.dart';
import 'package:frontend/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> storeUserDataInSharedPreference(ProfileModel model) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user', model.toJson());
      print(
          "All user data saved successfully in shared preference : ${model.toJson()}");
    } catch (e) {
      print("Error while storing user data $e");
    }
  }

  Future<void> storeAccessTokenInSharedPreference(String accessToken) async {
    try {
      //save in the sharedprefeces
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("accessToken", accessToken);
      print("Access token saved successfully : $accessToken");
    } catch (e) {
      print("Error while saving access token $e");
    }
  }

  Future<String?> getCurrentUser(String accessToken) async {
    try {
      //dio isntace
      Dio dio = Dio();
      //make dio get request as I have accessToken
      Response response = await dio.get(currentUser,
          options: Options(headers: {"Authorization": "Bearer $accessToken"}));
      //handle response
      if (response.statusCode == 200) {
        print("Current user get successfully ${response.data}");
        //store the user data in shared preference
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final user = ProfileModel.fromMap(response.data['data']);
        storeUserDataInSharedPreference(user);
      } else {
        print("Current user get failed ${response.statusCode}");
      }
    } catch (e) {
      print("Error while getting current user");
    }
    return null;
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      //create dio instance
      Dio dio = Dio();
      //make formdata instance only if you wnat to send data with image
      var data = {
        "email": email,
        "password": password,
      };
      //make dio post request
      Response response = await dio.post(login, data: data);

      //handle the response
      if (response.statusCode == 200) {
        print("User logged In successfully ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User logged In successfully, ${response.data}")));

        //Extract the access token from logged In user via sharedpreference
        final String? accessToken = response.data['data']['accessToken'];
        if (accessToken != null) {
          await storeAccessTokenInSharedPreference(accessToken);
          await getCurrentUser(accessToken);

          Navigator.pushNamedAndRemoveUntil(
              context, "/profile", (route) => false);
          return accessToken;
        } else {
          print("Acess token is not availabel in the response");
        }
      } else {
        print("Something wrong while logging ${response.statusCode}");
      }
    } catch (e) {
      print("Error while logging user $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade200,
        title: const Text("User Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
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
            const SizedBox(height: 30),
            MaterialButton(
              minWidth: double.maxFinite,
              height: 50,
              color: Colors.red.shade200,
              onPressed: isLoading
                  ? null
                  : () async {
                      await loginUser(
                        email: emailCtrl.text,
                        password: passwordCtrl.text,
                      );
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Register()));
              },
              child: RichText(
                text: TextSpan(
                    text: "Don't have an account ? \t",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: "Register here",
                          style: TextStyle(
                            color: Colors.red.shade400,
                          ))
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
