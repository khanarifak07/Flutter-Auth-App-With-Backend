import 'package:dio/dio.dart';

const wifiUrl = "http://192.168.0.107:4000/api/v1";
const mobileUrl = "https://192.168.142.11:4000/api/v1";
const url = wifiUrl;

Dio dio = Dio(BaseOptions(baseUrl: mobileUrl));

// const url = "https://flutter-auth-app-backend.onrender.com/api/v1";
const register = "$url/users/register";
const login = "$url/users/login";
const logout = "$url/users/logout";
const currentUser = "$url/users/current-user";
const updateProfileDetailsApi = "$url/users/update-account-details";
const changeCurrentPassword = "$url/users/change-current-password";
//todo
const createTodoApi = "$url/todos/create-todo";
String updateTodoApi(String id) => "$url/todos/update-todo/$id";
const getTodoApi = "$url/todos/get-todos";
