import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'dart:convert';

import 'package:multi_image_picker2/multi_image_picker2.dart';

class DocumentModel {
  int id;
  String userId;
  String name;
  String lastName;
  String date;
  String doctorName;
  String reason;
  String labName;
  String examType;
  int examTypeIndex;
  int isReviewed;
  int isSeen;
  String reviewDocNtcode;

  DocumentModel(
      {required this.id,
      required this.userId,
      required this.name,
      required this.lastName,
      required this.date,
      required this.doctorName,
      required this.reason,
      required this.labName,
      required this.examType,
      required this.examTypeIndex,
      required this.isReviewed,
      required this.isSeen,
      required this.reviewDocNtcode});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['last_name'] = this.lastName;
    data['date'] = this.date;
    data['doctor_name'] = this.doctorName;
    data['reason'] = this.reason;
    data['lab_name'] = this.labName;
    data['exam_type'] = this.examType;
    data['exam_type_index'] = this.examTypeIndex;
    data['is_reviewed'] = this.isReviewed;
    data['is_seen'] = this.isSeen;
    data['review_doc_ntcode'] = this.reviewDocNtcode;
    return data;
  }
}

class DocumentMediaModel {
  int mediaId;
  int docId;
  String docUrl;
  String docName;
  String docType;

  DocumentMediaModel(
      {required this.mediaId,
      required this.docId,
      required this.docUrl,
      required this.docName,
      required this.docType});
}

class AccessModel {
  int? accessId;
  String? docNtRef;
  String? userNtcode;
  int? accessedDoc;
  String? time;

  AccessModel(
      {this.accessId,
      this.docNtRef,
      this.userNtcode,
      this.accessedDoc,
      this.time});
}

class DocumentsProvider with ChangeNotifier {
  List<DocumentModel> _documents = [];
  List<DocumentMediaModel> _documentsMedia = [];
  List<AccessModel> _accessList = [];
  List<DocumentModel> _beforeSearchList = [];

  List<DocumentModel> get getDocuments {
    if (_beforeSearchList.length > 1) {
      return [..._beforeSearchList];
    } else {
      return [..._documents];
    }
  }

  List<DocumentMediaModel> get getDocumentsMedia {
    return [..._documentsMedia];
  }

  List<AccessModel> get getAccessList {
    return [..._accessList];
  }

  void runFilter(String enteredKeyword) {
    _beforeSearchList = _documents;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _documents;
    } else {
      List<DocumentModel> _filteredList = _documents
          .where((document) =>
              document.reason
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              document.doctorName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              document.labName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      _documents = [];
      _documents = _filteredList;
      // _filteredList.forEach((element) {
      //   print(element.name);
      // });
      _documents.forEach((element) {
        print(element.name);
      });
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchAndSetDocuments(
      String userNtcode, int examTypeIndex) async {
    _documents = [];
    List<dynamic> recivedData = [];
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/documents/get/$userNtcode/$examTypeIndex');

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        _documents.add(DocumentModel(
            id: recivedData[i]['id'],
            userId: recivedData[i]['user_id'],
            name: recivedData[i]['name'],
            lastName: recivedData[i]['last_name'],
            date: recivedData[i]['date'],
            doctorName: recivedData[i]['doctor_name'],
            reason: recivedData[i]['reason'],
            labName: recivedData[i]['lab_name'],
            examType: recivedData[i]['exam_type'],
            examTypeIndex: recivedData[i]['exam_type_index'],
            isReviewed: recivedData[i]['is_reviewed'],
            isSeen: recivedData[i]['is_seen'],
            reviewDocNtcode: recivedData[i]['review_doc_ntcode']));

        await _getDocumentsMediaFromServer(recivedData[i]['id'].toString());
      }
      notifyListeners();

      //await _getDocumentsMedia();
    } catch (e) {
      print('Error in Geting Documents ${e.toString()}');
    }
  }

  Future<void> fetchAndSetAllDocumentsByNtCode(String userNtcode) async {
    _documents = [];
    List<dynamic> recivedData = [];
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/documents/get/$userNtcode');

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        _documents.add(DocumentModel(
            id: recivedData[i]['id'],
            userId: recivedData[i]['user_id'],
            name: recivedData[i]['name'],
            lastName: recivedData[i]['last_name'],
            date: recivedData[i]['date'],
            doctorName: recivedData[i]['doctor_name'],
            reason: recivedData[i]['reason'],
            labName: recivedData[i]['lab_name'],
            examType: recivedData[i]['exam_type'],
            examTypeIndex: recivedData[i]['exam_type_index'],
            isReviewed: recivedData[i]['is_reviewed'],
            isSeen: recivedData[i]['is_seen'],
            reviewDocNtcode: recivedData[i]['review_doc_ntcode']));

        await _getDocumentsMediaFromServer(recivedData[i]['id'].toString());
      }
      notifyListeners();

      //await _getDocumentsMedia();
    } catch (e) {
      print('Error in Geting Documents ${e.toString()}');
    }
  }

  Future<void> _getDocumentsMediaFromServer(String docId) async {
    List<dynamic> recivedData;
    print("GetingMedia For Docid$docId");
    try {
      Uri url = Uri.parse(
          'https://api.mpmed.ir/public/index.php/app/general/document/media/get/id/$docId');

      final response = await http.get(url);

      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        if (!_documentsMedia.contains(recivedData[i]['media_id'])) {
          _documentsMedia.add(DocumentMediaModel(
              mediaId: recivedData[i]['media_id'],
              docId: recivedData[i]['doc_id'],
              docUrl: recivedData[i]['doc_url'],
              docName: recivedData[i]['doc_name'],
              docType: recivedData[i]['doc_type']));
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error in Geting Media ${e.toString()}');
    }
  }

  Future<Map> postDocumentData(Map map, List<Asset> files) async {
    Map responseData = {};

    Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/documents/create');

    try {
      final response =
          await http.post(url, body: json.encode(map)).catchError((onError) {
        print(onError.toString());
      }).then((value) async {
        responseData = json.decode(value.body);
        // if (responseData['success'] == true) {
        //   // await _uploadFiles(files, response['id'].toString());
        // }
      });
      // print(json.decode(response));
    } catch (e) {
      print(e.toString());
    }

    Map result = {
      'docId': responseData['id'].toString(),
      'success': responseData['success']
    };
    return result;
  }

  Future<bool> uploadFiles(List<Asset> files, String docId,
      List<ByteData> imagesFromPdf, bool isPdf) async {
    // var request = http.MultipartRequest('POST',
    //     Uri.parse('https://mpmed.ir/mp_app/v1/api.php?apicall=uploaddocmedia'));
    // request.files.add(await MultipartFile.fromFile(
    //     'media', file.identifier.toString(),
    //     filename: '${DateTime.now().microsecond.toString()}.png'));

    // request.fields['doc_id'] = docId;
    // request.fields['doc_type'] = 'png';
    // var res = await request.send();
    // print(res.stream.transform(utf8.decoder).listen((event) {
    //   print(event.toString());
    // }));
    bool _isDone = false;
    int counter = 0;
    if (isPdf) {
      for (var i = 0; i < imagesFromPdf.length; i++) {
        try {
          counter++;
          List<int> imageData = imagesFromPdf[i].buffer.asUint8List();
          MultipartFile multipartFile = MultipartFile.fromBytes(
            imageData,
            filename:
                '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg', //this is not nessessory variable. if this getting error, erase the line.
          );
          var dio = Dio();
          FormData formData = new FormData.fromMap(
              {'doc_id': docId, "media": multipartFile, 'doc_type': 'png'});
          Response resp = await dio.post(
            'https://mpmed.ir/mp_app/v1/api.php?apicall=uploaddocmedia',
            data: formData,
          );
          if (resp.statusCode == 200) {
            print("============= Print Resp data: ");
            print(resp.data);
          }
        } catch (e) {}
      }
      if (imagesFromPdf.length == counter) {
        _isDone = true;
        print('Uploading Done');
      }
    } else {
      for (var i = 0; i < files.length; i++) {
        try {
          counter++;
          ByteData byteData = await files[i].getByteData();
          List<int> imageData = byteData.buffer.asUint8List();
          MultipartFile multipartFile = MultipartFile.fromBytes(
            imageData,
            filename:
                '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg', //this is not nessessory variable. if this getting error, erase the line.
          );
          var dio = Dio();
          FormData formData = new FormData.fromMap(
              {'doc_id': docId, "media": multipartFile, 'doc_type': 'png'});
          Response resp = await dio.post(
            'https://mpmed.ir/mp_app/v1/api.php?apicall=uploaddocmedia',
            data: formData,
          );
          if (resp.statusCode == 200) {
            print("============= Print Resp data: ");
            print(resp.data);
          }
        } catch (e) {}
      }

      if (files.length == counter) {
        _isDone = true;
        print('Uploading Done');
      }
    }

    print('uploaded files $counter');
    return _isDone;
  }

  /////Access app

  Future<void> giveAccess(
      String doctorNtcode, String userNtcode, String docId) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctor/access/create');

    Map<String, dynamic> postData = {};
    postData["doc_nt_ref"] = doctorNtcode;
    postData["user_ntcode"] = userNtcode;
    postData["accessed_doc"] = int.parse(docId.toString());
    postData["time"] = DateTime.now().toString();
    try {
      final response = await http.post(url, body: json.encode(postData));
      Map recivedData = json.decode(response.body);

      if (recivedData['success'] == true) {
        print('Giving  access to doctor was successfull');
      }
    } catch (e) {
      print('error while giving access ${e.toString()}');
    }
  }

  Future<bool> checkAccess(String doctor_ntcode, String accessed_doc) async {
    bool _has_access = false;

    List<dynamic> recivedData = [];

    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctor/access/get/accesstable/$doctor_ntcode/$accessed_doc');

    try {
      final response = await http.get(url);

      if (response.body.isNotEmpty) {
        recivedData = json.decode(response.body);
      } else {
        _has_access = false;
      }

      for (var i = 0; i < recivedData.length; i++) {
        _accessList.add(AccessModel(
          accessId: recivedData[i]['access_id'],
          accessedDoc: recivedData[i]['accessed_doc'],
          docNtRef: recivedData[i]['doc_nt_ref'],
          time: recivedData[i]['time'],
          userNtcode: recivedData[i]['user_ntcode'],
        ));
        _has_access = true;
      }

      notifyListeners();
    } catch (e) {
      print('error while fetching accessTable ${e.toString()}');
      _has_access = false;
    }

    return _has_access;
  }

  Future<void> editDocument(Map map) async {
    print(map['id'].toString());
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/documents/${map['id'].toString()}');

    try {
      final response = await http.put(url, body: json.encode(map));
      Map recivedData = jsonDecode(response.body);
      if (recivedData['success'] == true) {
        print('Updating document successfull');
      }
    } catch (e) {}
  }

  Future<void> deleteDocument(
      String docId, String userNtcode, int examTypeIndex) async {
    final Uri url =
        Uri.parse('https://api.mpmed.ir/public/index.php/documents/$docId');

    try {
      final response = await http.delete(url);
      Map recivedData = jsonDecode(response.body);
      if (recivedData['success'] == true) {
        fetchAndSetDocuments(userNtcode, examTypeIndex);
        print("deleting document Successfull!!!");
      }
    } catch (e) {
      print('Error in Updating Document Error:${e.toString()}');
    }
    notifyListeners();
  }
}
