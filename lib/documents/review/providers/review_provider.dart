import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpmed_patient/documents/Review/model/review_model.dart';
import 'package:http/http.dart' as http;

class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviewList = [];

  List<ReviewModel> get getReviews {
    return [...{..._reviewList}];
  }

  Future<void> fetchAndSetReview(
      String doctor_ntcode, String document_id) async {
    print('Doctor_id=$doctor_ntcode  Document_id=$document_id');
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/review-document/get/doctor/$document_id/$doctor_ntcode/');
    List<dynamic> recivedData;
    _reviewList = [];

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      print(recivedData.toString());

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
    } catch (e) {
      print('Error while fetching reviews ${e.toString()}');
    }
  }

  Future<void> fetchAndSetAllReviews(String document_id) async {
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
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> createReview(
      String docId, String message, String doctor_nt_code) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/review-document/create');

    Map<String, dynamic> postData = {};
    postData["document_id"] = int.parse(docId.toString());
    postData["doctor_id"] = doctor_nt_code;
    postData["content"] = message;
    postData["time"] = DateTime.now().millisecondsSinceEpoch.toString();
    postData["doctor_answer"] = 0;
    postData["user_answer"] = 1;

    try {
      final response = await http.post(url, body: json.encode(postData));

      Map recivedData = json.decode(response.body);

      if (recivedData['success'] == true) {
        fetchAndSetReview(doctor_nt_code, docId);
        // isGettingPatientReportLoading = false;
        // getReportsByUserId(userId);
        // _showSnackBar(Colors.green, 'report deleted successfully',
        //     patientReportScaffoldKey);
      } else {
        // isGettingPatientReportLoading = false;
        // _showSnackBar(
        //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
      }
      if (response.statusCode>= 400) {
        // isGettingPatientReportLoading = false;
        // _showSnackBar(
        //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
      } else {
        // isGettingPatientReportLoading = false;
      }
    } catch (e) {
      print('Error While Sending Review ${e.toString()}');
    }
  }
}
