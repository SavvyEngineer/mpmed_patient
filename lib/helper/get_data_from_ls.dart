import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class GetDataFromLs {
  final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};
  Map authData = {};

  Map get getProfileMapData {
    getProfileData().then((value) {
      userData = value;
    });
    return userData;
  }

  Future<Map> getProfileData() async {
    await storage.ready;
    userData = storage.getItem('profile');
    return userData;
  }

  Future<Map> getAuthData() async {
    await storage.ready;
    authData = storage.getItem('authData');
    return authData;
  }

  String getAuthToken() {
    getAuthData();
    print(authData['token']);
    authData.forEach((key, value) {
      print('key==$key---value==$value');
    });
    return authData['token'];
  }

  String getAuthRefreshToken() {
    getAuthData();
    return authData['refresh_token'];
  }
}
