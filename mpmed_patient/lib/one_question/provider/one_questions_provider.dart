import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OneQuestionParticipants {
  String? name;
  String? lastName;
  String? specialty;
  String? profile_pic;
  String? nationalCode;
  String? notifToken;

  OneQuestionParticipants(
      {this.name,
      this.lastName,
      this.specialty,
      this.profile_pic,
      this.nationalCode,
      this.notifToken});

  OneQuestionParticipants.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lastName = json['lastName'];
    specialty = json['specialty'];
    profile_pic = json['profile_pic'];
    nationalCode = json['national_code'];
    notifToken = json['notif_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['lastName'] = this.lastName;
    data['specialty'] = this.specialty;
    data['profile_pic'] = this.profile_pic;
    data['national_code'] = this.nationalCode;
    data['notif_token'] = this.notifToken;
    return data;
  }
}

class OneQuestionModel {
  int? questionId;
  String? userRefId;
  String? content;
  String? time;
  String? doctorRefId;
  int? doctorAnswer;
  int? userAnswer;

  OneQuestionModel(
      {this.questionId,
      this.userRefId,
      this.content,
      this.time,
      this.doctorRefId,
      this.doctorAnswer,
      this.userAnswer});

  OneQuestionModel.fromJson(Map<String, dynamic> json) {
    questionId = json['question_id'];
    userRefId = json['user_ref_id'];
    content = json['content'];
    time = json['time'];
    doctorRefId = json['doctor_ref_id'];
    doctorAnswer = json['doctor_answer'];
    userAnswer = json['user_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_id'] = this.questionId;
    data['user_ref_id'] = this.userRefId;
    data['content'] = this.content;
    data['time'] = this.time;
    data['doctor_ref_id'] = this.doctorRefId;
    data['doctor_answer'] = this.doctorAnswer;
    data['user_answer'] = this.userAnswer;
    return data;
  }
}

class OneQuestionsProvider with ChangeNotifier {
  List<OneQuestionParticipants> _one_question_users_list = [];
  List<OneQuestionModel> _one_question_items_list = [];

  List<OneQuestionParticipants> get getOneQuestionUsers {
    return [..._one_question_users_list];
  }

  List<OneQuestionModel> get getOneQuestionItems {
    return [..._one_question_items_list];
  }

  void runFilterOnParticipants(String enteredKeyword) {
    List<OneQuestionParticipants> _beforeSearchList = _one_question_users_list;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _one_question_users_list;
    } else {
      List<OneQuestionParticipants> _filteredList = _one_question_users_list
          .where((questionParticipant) =>
              questionParticipant.name!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              questionParticipant.lastName!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      _one_question_users_list = [];
      _one_question_users_list = _filteredList;
      // _filteredList.forEach((element) {
      //   print(element.name);
      // });
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchOneQuestionUsers(String userNtcode) async {
    _one_question_users_list = [];
    List<dynamic> recivedData = [];

    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/get/participants/{doctor_nt_code}/$userNtcode/user');

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);
      for (var i = 0; i < recivedData.length; i++) {
        _one_question_users_list.add(OneQuestionParticipants(
            name: recivedData[i][0]['name'],
            lastName: recivedData[i][0]['lastName'],
            specialty: recivedData[i][0]['specialty'],
            profile_pic: recivedData[i][0]['profile_pic'],
            nationalCode: recivedData[i][0]['national_code'],
            notifToken: recivedData[i][0]['notif_token']));
      }
    } catch (e) {
      print(
          'Error while fetching OneQuestion Participants Error: ${e.toString()}');
    }
    notifyListeners();
  }

  Future<void> fetchQuestions(String userNtcode, String doctorNtcode) async {
    _one_question_items_list = [];
    List<dynamic> recivedData = [];

    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/get/$userNtcode/$doctorNtcode');

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);
      for (var i = 0; i < recivedData.length; i++) {
        _one_question_items_list.add(OneQuestionModel(
            content: recivedData[i]['content'],
            doctorAnswer: recivedData[i]['doctor_answer'],
            doctorRefId: recivedData[i]['doctor_ref_id'],
            questionId: recivedData[i]['question_id'],
            time: recivedData[i]['time'],
            userAnswer: recivedData[i]['user_answer'],
            userRefId: recivedData[i]['user_ref_id']));
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> createQuestion(String user_ref_id, String doctor_ref_id,
      String content, String time) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/create');

    Map<String, dynamic> map = {
      "question_id": 0,
      "user_ref_id": user_ref_id,
      "doctor_ref_id": doctor_ref_id,
      "content": content,
      "time": time,
      "doctor_answer": 0,
      "user_answer": 1
    };

    try {
      final response = await http.post(url, body: json.encode(map));
      Map recivedData = json.decode(response.body);
      if (recivedData["success"]) {
        print('Question Submitted SuccessFully');
      }
    } catch (e) {
      print('Error while Submitting question Error: ${e.toString()}');
    }
  }
}
