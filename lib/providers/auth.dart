// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/userdata.dart';
import 'package:shop_app/providers/constants.dart';
import 'dart:convert';

import '../models/http_exception.dart';

const FireBase_API = 'AIzaSyC2gGuz_F8k6zMKpCPiX426AFc4iBCzBRg';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userName;
  Timer? _authTimer;
  String? _photoURL;
  String? _name;
  UserData? userProfile;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    // if (_expiryDate != null &&
    //     _expiryDate!.isAfter(DateTime.now()) &&
    //     _token != null) {
    //   return _token.toString();
    // }
    return _token.toString();
  }

  String get userId {
    return _userName.toString();
  }

  Future<void> signUp(
      String name,
      String dateOfBirth,
      String gender,
      String phoneNumber,
      String email,
      String username,
      String password) async {
    return _authenticate(
        username,
        password,
        {
          'name': name,
          'dateOfBirth': dateOfBirth,
          'phoneNumber': phoneNumber,
          'email': email,
          'gender': gender,
        },
        'signUp');
  }

  Future<void> signIn(String username, String password) async {
    return _authenticate(username, password, {}, 'signInWithPassword');
  }

  Future<void> _authenticate(String username, String password,
      Map<String, String>? extraData, String urlSegment) async {
    // final url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$FireBase_API');
    switch (urlSegment) {
      case "signInWithPassword":
        {
          await signInWithPassword(username, password);
          break;
        }
      case "signUp":
        {
          await signUpWithInfoPlayer(username, password, extraData);
          break;
        }
      default:
        {
          break;
        }
    }
  }

  Future<UserData?> getUserData() async {
    final url = Uri.parse("${Constant.baseUrl}/api/Account/profile");

    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')!);
    _token = extractedUserData['token'];

    try {
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = UserData.fromJson(responseData);
        return user;
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (error) {
      rethrow;
    }
  }


  Future<void> signUpWithInfoPlayer(
      String username, String password, Map<String, String>? extraData) async {
    final url = Uri.parse("${Constant.baseUrl}/api/Account/register");
    try {
      final response = await http.post(url,
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            ...?extraData,
            'userName': username,
            'password': password,
          }));
      print(response.body);
    } catch (_error) {
      print(_error);
      rethrow;
    }
  }

  Future<void> signInWithPassword(String username, String password) async {
    final url = Uri.parse("${Constant.baseUrl}/api/Account/login");
    try {
      var reponse = await http.post(url,
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'userName': username,
            'password': password,
          }));
      if (reponse.statusCode == 200) {
        final responseData = jsonDecode(reponse.body);
        _token = responseData['token'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          "token": _token,
        });
        //await getUserData();
        prefs.setString('userData', userData);
      } else {
        throw HttpException(reponse.body);
      }
    } catch (_error) {
      print(_error);
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, dynamic>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userName = extractedUserData['userName'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userName = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }


}
