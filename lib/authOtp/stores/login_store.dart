import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mobx/mobx.dart';
import 'package:mpmed_patient/authOtp/pages/sign_up_page.dart';
import 'package:mpmed_patient/authOtp/stores/user_pojo.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:mpmed_patient/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../pages/otp_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  final LocalStorage storage = new LocalStorage('userData');
  late FirebaseMessaging messaging;

  @observable
  bool isLoginLoading = false;
  @observable
  bool isOtpLoading = false;
  @observable
  bool isSignUpLoading = false;

  @observable
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> signUpScaffoldKey = GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();

  @action
  Future<bool> isAlreadyAuthenticated() async {
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('userData')) {
    //   return false;
    // }
    // return true;
    await storage.ready;
    if (storage.getItem('profile') == null) {
      return false;
    }
    return true;
  }

  @action
  Future<void> getCodeWithPhoneNumber(
      BuildContext context, String phoneNumber) async {
    isLoginLoading = true;

    // await _auth.verifyPhoneNumber(
    //     phoneNumber: phoneNumber,
    //     timeout: const Duration(seconds: 60),
    //     verificationCompleted: (AuthCredential auth) async {
    //       await _auth.signInWithCredential(auth).then((AuthResult value) {
    //         if (value != null && value.user != null) {
    //           print('Authentication successful');
    //           onAuthenticationSuccessful(context, value);
    //         } else {
    //           loginScaffoldKey.currentState.showSnackBar(SnackBar(
    //             behavior: SnackBarBehavior.floating,
    //             backgroundColor: Colors.red,
    //             content: Text(
    //               'Invalid code/invalid authentication',
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ));
    //         }
    //       }).catchError((error) {
    //         loginScaffoldKey.currentState.showSnackBar(SnackBar(
    //           behavior: SnackBarBehavior.floating,
    //           backgroundColor: Colors.red,
    //           content: Text(
    //             'Something has gone wrong, please try later',
    //             style: TextStyle(color: Colors.white),
    //           ),
    //         ));
    //       });
    //     },
    //     verificationFailed: (AuthException authException) {
    //       print('Error message: ' + authException.message);
    //       loginScaffoldKey.currentState.showSnackBar(SnackBar(
    //         behavior: SnackBarBehavior.floating,
    //         backgroundColor: Colors.red,
    //         content: Text(
    //           'The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]',
    //           style: TextStyle(color: Colors.white),
    //         ),
    //       ));
    //       isLoginLoading = false;
    //     },
    //     codeSent: (String verificationId, [int forceResendingToken]) async {
    //       actualCode = verificationId;
    //       isLoginLoading = false;
    //       await Navigator.of(context)
    //           .push(MaterialPageRoute(builder: (_) => const OtpPage()));
    //     },
    //     codeAutoRetrievalTimeout: (String verificationId) {
    //       actualCode = verificationId;
    //     });

    final url = 'https://mpmed.ir/user_auth/validate_national_code.php';

    try {
      var map = new Map<String, dynamic>();
      map["ntcode"] = phoneNumber;

      final response = await http.post(Uri.parse(url), body: map);

      final responseData = json.decode(response.body);

      print(responseData.toString());

      if (response.statusCode >= 400) {
        isLoginLoading = false;
        loginScaffoldKey.currentState!.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
        ));
        return;
      }

      if (responseData['error'] == false) {
        isLoginLoading = false;
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const OtpPage()));
      } else {
        // loginScaffoldKey.currentState!.showSnackBar(SnackBar(
        //   behavior: SnackBarBehavior.floating,
        //   backgroundColor: Colors.red,
        //   content: Text(
        //     'The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]',
        //     style: TextStyle(color: Colors.white),
        //   ),
        // ));

        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => SignUpPage(phoneNumber)));
        isLoginLoading = false;
      }
    } catch (e) {
      isLoginLoading = false;
      print(e.toString());
    }
  }

  @action
  Future<void> signUp(BuildContext context, Map<String, dynamic> map) async {
    isSignUpLoading = true;
    final url = 'https://mpmed.ir/user_auth';
    try {
      String FileName = DateTime.now().millisecondsSinceEpoch.toString();
      messaging = FirebaseMessaging.instance;
      await messaging.getToken().then((value) async {
        map['notif_token'] = value;
      });

      map.forEach((key, value) {
        print('key=$key == value=$value');
      });
      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;
      final response = await dio
          .post("/request_sms.php", data: formData)
          .then((response) async {
        if (response.statusCode! >= 400) {
          isSignUpLoading = false;
          signUpScaffoldKey.currentState!.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
          ));
          return;
        }

        print(response.data.toString());

        Map recivedData = json.decode(response.data);
        if (recivedData['error'] == false) {
          isSignUpLoading = false;
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const OtpPage()));
        } else {
          isSignUpLoading = false;
          loginScaffoldKey.currentState!.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'SignUp Unsecessfull',
              style: TextStyle(color: Colors.white),
            ),
          ));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @action
  Future<void> validateOtpAndLogin(BuildContext context, String smsCode) async {
    isOtpLoading = true;
    // final AuthCredential _authCredential = PhoneAuthProvider.getCredential(
    //     verificationId: actualCode, smsCode: smsCode);

    // await _auth.signInWithCredential(_authCredential).catchError((error) {
    //   isOtpLoading = false;
    //   otpScaffoldKey.currentState.showSnackBar(SnackBar(
    //     behavior: SnackBarBehavior.floating,
    //     backgroundColor: Colors.red,
    //     content: Text(
    //       'Wrong code ! Please enter the last code received.',
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   ));
    // }).then((AuthResult authResult) {
    //   if (authResult != null && authResult.user != null) {
    //     print('Authentication successful');
    //     onAuthenticationSuccessful(context, authResult);
    //   }
    // });

    final url = 'https://mpmed.ir/user_auth/verify_otp.php';

    try {
      var map = new Map<String, String>();
      map["otp"] = smsCode;

      final response =
          await http.post(Uri.parse(url), body: map).catchError((error) {
        isOtpLoading = false;
        otpScaffoldKey.currentState!.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Wrong code ! Please enter the last code received.',
            style: TextStyle(color: Colors.white),
          ),
        ));
      }).then((value) {
        final responseData = json.decode(value.body);
        print(responseData.toString());
        if (responseData['error'] != true) {
          print('Authentication successful');
          getAuthToken(responseData, context);
        }
      });

      if (response.statusCode >= 400) {
        isOtpLoading = false;
        loginScaffoldKey.currentState!.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
        ));
        return;
      }

      final responseData = json.decode(response.body);

      print(responseData.toString());

      if (responseData['error'] == false) {
        isLoginLoading = false;
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const OtpPage()));
      } else {
        loginScaffoldKey.currentState!.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]',
            style: TextStyle(color: Colors.white),
          ),
        ));
        isLoginLoading = false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getAuthToken(dynamic responseData, BuildContext context) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://api.mpmed.ir/public/consumer/login'));
    request.body = json.encode({
      "username": responseData['profile']['national_code'],
      "password": responseData['profile']['apikey']
    });
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final authResult = jsonDecode(response.body) as Map<String, dynamic>;
      onAuthenticationSuccessful(context, responseData['profile'], authResult);
      print(response.body.toString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> onAuthenticationSuccessful(BuildContext context,
      Map<String, dynamic> profileData, Map<String, dynamic> authData) async {
    late FirebaseMessaging messaging;
    isLoginLoading = true;
    isOtpLoading = true;

    // firebaseUser = result.user;

    // final prefs = await SharedPreferences.getInstance();
    // print('user Data: {{{  $result');
    // prefs.setString('userData', json.encode(result));
    await storage.ready;
    storage.setItem('profile', profileData);
    storage.setItem('authData', authData);

    messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .registerToken(value.toString(),profileData['national_code']);
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (Route<dynamic> route) => false);

    isLoginLoading = false;
    isOtpLoading = false;
  }

  @action
  Future<void> signOut(BuildContext context) async {
    // await _auth.signOut();
    // await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (Route<dynamic> route) => false);
    // firebaseUser = null;
  }

  // @action
  // Future<void> setUpNotifToken(String _notifToken) async {
  //   Map<String, dynamic> data = storage.getItem('profile');
  //   final doctor = Profile.fromJson(data);

  //   print(doctor.notifToken);
  //   print(doctor.nationalCode);

  //   final url = 'https://mpmed.ir:8801/api/v2/tokens';

  //   print(_notifToken.toString());

  //   try {
  //     final response = await http.post(Uri.parse(url), body: {
  //       "device": "fcm",
  //       "token": _notifToken,
  //       "channel": "default"
  //     }, headers: {
  //       "X-AN-APP-NAME": "mizepezeskdoctor",
  //       "X-AN-APP-KEY": "6ac0b9fb979e35e366b5056d3f5e41e8"
  //     }).catchError((error) {
  //       print(error.toString());
  //     }).then((value) => print('respnse data ${value.statusCode}'));
  //     // final responseData = json.decode(response.body);
  //     // print('respnse data ${responseData.toString()}');
  //     // print('respnse data ${response.statusCode}');

  //     // if (response.statusCode >= 400) {
  //     //   print(response.statusCode.toString());
  //     //   return;
  //     // }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}
