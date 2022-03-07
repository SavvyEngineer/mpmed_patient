import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/doctors/screen/doctors_list_screen.dart';
import 'package:mpmed_patient/documents/Review/model/review_model.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';

class DoctorModel {
  int? id;
  String? mdCode;
  String? specialty;
  String? name;
  String? email;
  String? mobile;
  String? apikey;
  int? status;
  String? createdAt;
  String? lastname;
  String? fathername;
  String? birthdate;
  String? wcity;
  String? wstate;
  String? nationalCode;
  bool? isApproved;
  bool? usedMdApp;
  String? profilePic;
  Null? rate;
  String? notifToken;

  DoctorModel(
      {this.id,
      this.mdCode,
      this.specialty,
      this.name,
      this.email,
      this.mobile,
      this.apikey,
      this.status,
      this.createdAt,
      this.lastname,
      this.fathername,
      this.birthdate,
      this.wcity,
      this.wstate,
      this.nationalCode,
      this.isApproved,
      this.usedMdApp,
      this.profilePic,
      this.rate,
      this.notifToken});
}

class WorkingHourModel {
  int? id;
  String? doctorRefId;
  String? editedTime;
  String? day0;
  String? day1;
  String? day2;
  String? day3;
  String? day4;
  String? day5;
  String? day6;

  WorkingHourModel(
      {this.id,
      this.doctorRefId,
      this.editedTime,
      this.day0,
      this.day1,
      this.day2,
      this.day3,
      this.day4,
      this.day5,
      this.day6});

  WorkingHourModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorRefId = json['doctor_ref_id'];
    editedTime = json['edited_time'];
    day0 = json['day_0'];
    day1 = json['day_1'];
    day2 = json['day_2'];
    day3 = json['day_3'];
    day4 = json['day_4'];
    day5 = json['day_5'];
    day6 = json['day_6'];
  }

Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_ref_id'] = this.doctorRefId;
    data['edited_time'] = this.editedTime;
    data['day_0'] = this.day0;
    data['day_1'] = this.day1;
    data['day_2'] = this.day2;
    data['day_3'] = this.day3;
    data['day_4'] = this.day4;
    data['day_5'] = this.day5;
    data['day_6'] = this.day6;
    return data;
  }
}

class DoctorProvider with ChangeNotifier {
  List<DoctorModel> _doctorsList = [];
  List<ReviewModel> _reviewList = [];
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  List<WorkingHourModel> _workingHourModel = [];
  List<String> _workingHourByDay = [];

  List<DoctorModel> get getDoctorsList {
    return [..._doctorsList];
  }

  List<ReviewModel> get getReviewList {
    return [..._reviewList];
  }

  List<String> get getWorkingHoursByDay {
    return [..._workingHourByDay];
  }

  List<WorkingHourModel> get getWorkingHours {
    return [..._workingHourModel];
  }

  Future<void> refreshAuth() async {
    print("RefreshToken==${getDataFromLs.getAuthRefreshToken()}");
    var headers = {
      'Authorization':
          'Basic OGFiMTdiOTAtZmMzYy00ZjYyLTljYzMtMzlkZGEzZjNkMTM0OmRlZGQ3Nzg2ODkyZTc5ZmJjMmY5ODQ1ZThiYTdiODQ1ZWI0ZjIwMzVjN2VlOTJiNzhiZmYwNTMxNTM5MTViM2I=',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request('POST',
        Uri.parse('https://api.mpmed.ir/public/index.php/authorization/token'));
    request.bodyFields = {
      'grant_type': 'refresh_token',
      'refresh_token': getDataFromLs.getAuthRefreshToken()
    };
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final LocalStorage storage = new LocalStorage('userData');
      final authResult = jsonDecode(response.body) as Map<String, dynamic>;
      Map authData = {
        'token': authResult['access_token'],
        'expires_in': authResult['expires_in'],
        'refresh_token': authResult['refresh_token']
      };
      await storage.ready;
      storage.deleteItem('authData');
      storage.setItem('authData', authData);
    } else {
      print(response.reasonPhrase);
    }
  }

  void runFilter(String enteredKeyword) {
    List<DoctorModel> _beforeSearchList = _doctorsList;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _doctorsList;
    } else {
      List<DoctorModel> _filteredList = _doctorsList
          .where((doctor) =>
              doctor.name!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.lastname!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.specialty!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.wcity!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.wstate!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase())
                  )
          .toList();

      _doctorsList = [];
      _doctorsList = _filteredList;
      // _filteredList.forEach((element) {
      //   print(element.name);
      // });
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchDoctorsList() async {
    final Uri url = Uri.parse(
        "https://api.mpmed.ir/public/index.php/app/general/doctors/list/get");
    await getDataFromLs.getAuthData();
    String token = getDataFromLs.getAuthToken().toString();
    print('Access token===$token');

    var headers = {'Authorization': 'Bearer $token'};

    List<dynamic> recivedData;
    _doctorsList = [];

    try {
      final response = await http.get(url);
      print(response.body.toString());
      if (response.statusCode == 401) {
        // refreshAuth().then((value) {
        //   fetchDoctorsList();
        // });
      } else {
        recivedData = json.decode(response.body);
        for (var i = 0; i < recivedData.length; i++) {
          _doctorsList.add(DoctorModel(
            id: recivedData[i]['id'],
            mdCode: recivedData[i]['md_code'],
            specialty: recivedData[i]['specialty'],
            name: recivedData[i]['name'],
            email: recivedData[i]['email'],
            mobile: recivedData[i]['mobile'],
            apikey: recivedData[i]['apikey'],
            status: recivedData[i]['status'],
            createdAt: recivedData[i]['created_at'],
            lastname: recivedData[i]['lastname'],
            fathername: recivedData[i]['fathername'],
            birthdate: recivedData[i]['birthdate'],
            wcity: recivedData[i]['wcity'],
            wstate: recivedData[i]['wstate'],
            nationalCode: recivedData[i]['national_code'],
            isApproved: recivedData[i]['is_approved'],
            usedMdApp: recivedData[i]['used_md_app'],
            profilePic: recivedData[i]['profile_pic'],
            rate: recivedData[i]['rate'],
            notifToken: recivedData[i]['notif_token'],
          ));
        }
      }
    } catch (e) {
      print('Error While fetching Doctors List error:${e.toString()}');
    }
    notifyListeners();
  }

  Future<bool> fetchAndSetAllReviews(String document_id) async {
    bool _is_reviewed = false;
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/review-document/get/all/$document_id');
    List<dynamic> recivedData;
    _reviewList = [];

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        _reviewList.add(ReviewModel(
            reviewId: recivedData[i]['review_id'],
            content: recivedData[i]['content'],
            time: recivedData[i]['time'],
            doctorId: recivedData[i]['doctor_id'],
            doctorAnswer: recivedData[i]['doctor_answer'],
            userAnswer: recivedData[i]['user_answer']));
      }
      notifyListeners();
      _is_reviewed = true;
    } catch (e) {
      print('error while fetching all reviews ${e.toString()}');
      _is_reviewed = false;
    }
    return _is_reviewed;
  }

  Future<void> fetchAndSetWorkingHours(String doctor_ntcode) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctors/working_hour/$doctor_ntcode');

    List<dynamic> recivedData;
    List<WorkingHourModel> loadedData = [];
    _workingHourByDay = [];

    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(WorkingHourModel(
          id: recivedData[i]['id'],
          doctorRefId: recivedData[i]['doctor_ref_id'],
          editedTime: recivedData[i]['edited_time'],
          day0: recivedData[i]['day_0'],
          day1: recivedData[i]['day_1'],
          day2: recivedData[i]['day_2'],
          day3: recivedData[i]['day_3'],
          day4: recivedData[i]['day_4'],
          day5: recivedData[i]['day_5'],
          day6: recivedData[i]['day_6'],
        ));

        _workingHourByDay = [
          recivedData[i]['day_0'],
          recivedData[i]['day_1'],
          recivedData[i]['day_2'],
          recivedData[i]['day_3'],
          recivedData[i]['day_4'],
          recivedData[i]['day_5'],
          recivedData[i]['day_6'],
        ];
      }
      _workingHourModel = loadedData;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
