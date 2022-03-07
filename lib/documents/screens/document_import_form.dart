import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/screens/document_image_picker.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as imglib;

import 'documents_screen.dart';

class DocumentImportForm extends StatefulWidget {
  static const String routeName = '/document_import_form';

  @override
  State<DocumentImportForm> createState() => _DocumentImportFormState();
}

class _DocumentImportFormState extends State<DocumentImportForm> {
  String? _examTypeString;
  List<Asset>? _recivedDocImages;
  GlobalKey<FormState> _document_form_key = new GlobalKey();
  bool _isLoading = false;
  bool _is_init = true;
  bool _is_edit = false;
  List<ByteData>? imagesFromPdf;
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map documentData = {};
  Map userData = {};
  List<String> _examTypes = [
    'آزمایش خون',
    'تصویربرداری',
    'پاتولوژی',
    'سونوگرافی',
    'قلب وعروق'
  ];
  Map map = {};
  bool _is_doc_pdf = false;
  bool _is_doc_img = false;
  String date_label = Jalali.now().formatCompactDate();

  final _examTypeFocusNode = FocusNode();
  final _patientNameFocusNode = FocusNode();
  final _patientLastNameFocusNode = FocusNode();
  final _examDateFocusNode = FocusNode();
  final _examDoctorNameFocusNode = FocusNode();
  final _examReasonFocusNode = FocusNode();
  final _examLabNameFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_is_init) {
      print('Getting Inital Data');
      getDataFromLs.getProfileData().then((value) {
        userData = value;
      });
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final Map recivedMap =
            ModalRoute.of(context)!.settings.arguments as Map;
        documentData = recivedMap['DocumentData'];
        _examTypeString = _examTypes.elementAt(documentData['exam_type_index']);
        _is_edit = true;
        date_label = documentData['date'];
      }
      // documentData.forEach((key, value) {
      //   print('key==$key-----value==$value');
      // });
    }
    _is_init = false;
  }

  @override
  void dispose() {
    _examTypeFocusNode.dispose();
    _patientNameFocusNode.dispose();
    _patientLastNameFocusNode.dispose();
    _examDateFocusNode.dispose();
    _examDoctorNameFocusNode.dispose();
    _examReasonFocusNode.dispose();
    _examLabNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _editDocument(Map map) async {
    setState(() {
      _isLoading = true;
    });
    _document_form_key.currentState!.save();

    map['id'] = documentData['id'];
    map["user_id"] = documentData['user_id'];
    map["exam_type"] = _examTypeString.toString();
    map["exam_type_index"] = _examTypes.indexOf(_examTypeString.toString());
    map["is_reviewed"] = true;
    map["is_seen"] = true;
    map["review_doc_ntcode"] = documentData['review_doc_ntcode'];
    map["date"] = date_label;

    map.forEach((key, value) {
      print('key==$key----value=$value');
    });
    await Provider.of<DocumentsProvider>(context, listen: false)
        .editDocument(map)
        .then((value) {
      setState(() {
        _isLoading = false;
        EasyLoading.dismiss();
      });
      Navigator.of(context).pop();
      Navigator.of(context).popAndPushNamed(DocumentsScreen.routeName,
          arguments: {
            "exam_type_index": _examTypes.indexOf(_examTypeString.toString())
          });
      EasyLoading.showSuccess('مدارک شما با موفقیت ویرایش شد');
    });
  }

  Widget _TextReciver(
    String hinttext,
    String key,
    TextInputAction textInputAction,
    TextInputType textInputType,
    FocusNode focusNode,
    FocusNode _nextFocus,
  ) {
    var initialValue = '';
    if (_is_edit) {
      print('edit mode');
      initialValue = documentData[key];
      // initialValue = map[key];
    }
    //  else {
    //   if (key == 'name') {
    //     // print(userData['name'].toString());

    //     initialValue = userData['name'];
    //   }
    //   if (key == 'last_name') {
    //     initialValue = userData['lastName'];
    //   }
    // }
    return new TextFormField(
      keyboardType: textInputType,
      textInputAction: textInputAction,
      initialValue: initialValue,
      focusNode: focusNode,
      onFieldSubmitted: (_) {
        if (textInputAction != TextInputAction.done) {
          FocusScope.of(context).requestFocus(_nextFocus);
        }
      },

      decoration: InputDecoration(
          labelText: hinttext,
          alignLabelWithHint: true,
          hintText: hinttext,
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintStyle: TextStyle(
              fontWeight: FontWeight.w300, fontSize: 14.0, color: Colors.white),
          errorStyle: TextStyle(color: Colors.redAccent),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),

      // validator: FormValidator().validateEmail,
      onSaved: (value) {
        map[key] = value.toString();
      },
    );
  }

  void _reciveSelectedImages(BuildContext context) async {
    _recivedDocImages =
        await Navigator.pushNamed(context, DocumentImagePicker.routeName)
            as List<Asset>;
    if (_recivedDocImages!.length > 0) {
      setState(() {
        _is_doc_img = true;
      });
    }
  }

  void _reciveSelectedPdf() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      // File file = File(result.files.single.path.toString());
      imagesFromPdf = await pdfToImage(result.files.single.path.toString());
      setState(() {
        _is_doc_pdf = true;
      });
      // images.forEach((element) {
      //   print(element.identifier.toString());
      // });
    } else {
      setState(() {
        _is_doc_pdf = false;
      });
      // User canceled the picker
    }
  }

  Future<List<ByteData>> pdfToImage(String pdf) async {
    final doc = await PdfDocument.openFile(pdf);
    final pages = doc.pageCount;
    List<ByteData> images = [];

// get images from all the pages
    for (int i = 1; i <= pages; i++) {
      var page = await doc.getPage(i);
      var imgPDF = await page.render();
      var img = await imgPDF.createImageDetached();
      var imgBytes = await img.toByteData(format: ImageByteFormat.png);
      images.add(imgBytes as ByteData);
    }
    return images;
  }

  Future<void> _pushDocumentToServer(
      BuildContext context, Map documentData, List<Asset> files) async {
    _isLoading = true;
    _document_form_key.currentState!.save();
    map["user_id"] = userData['national_code'].toString();
    map["exam_type"] = _examTypeString.toString();
    map["exam_type_index"] = _examTypes.indexOf(_examTypeString.toString());
    map["is_reviewed"] = true;
    map["is_seen"] = true;
    map["review_doc_ntcode"] = "";
    map["date"] = date_label;

    await Provider.of<DocumentsProvider>(context, listen: false)
        .postDocumentData(documentData, files)
        .then((value) async {
      print("Uploading Files ....");
      if (value['success']) {
        print("Uploading Files Started");
        await Provider.of<DocumentsProvider>(context, listen: false)
            .uploadFiles(files, value['docId'], imagesFromPdf!, _is_doc_pdf)
            .then((value) {
          if (value) {
            EasyLoading.dismiss();
            Navigator.of(context).pop();
            Navigator.of(context)
                .popAndPushNamed(DocumentsScreen.routeName, arguments: {
              "exam_type_index": _examTypes.indexOf(_examTypeString.toString())
            });
            EasyLoading.showSuccess('مدارک شما با موفقیت ثبت شد');
          }
        });
      }
    });
  }

  void _onLoading() {
    if (_isLoading) {
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return Dialog(
      //       child: new Row(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           new CircularProgressIndicator(),
      //           new Text("Loading"),
      //         ],
      //       ),
      //     );
      //   },
      // );
      EasyLoading.show(status: 'بارگذاری...');
    }
  }

  Widget importDocMediaWidget() {
    if (!_is_doc_pdf && !_is_doc_img) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FlatButton(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.blue, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              child: Text('فایل pdf مدارک پزشکی شما',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              onPressed: () {
                _reciveSelectedPdf();
              }),
          SizedBox(
            width: 8,
          ),
          FlatButton(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.blue, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
              child: Text('عکس مدارک پزشکی شما',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              onPressed: () {
                _reciveSelectedImages(context);
              }),
        ],
      );
    } else {
      if (_is_doc_pdf) {
        return FlatButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.blue, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(50)),
            child: Text('فایل pdf مدارک پزشکی شما',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            onPressed: () {
              _reciveSelectedPdf();
            });
      } else {
        return FlatButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.blue, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(50)),
            child: Text('عکس مدارک پزشکی شما',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            onPressed: () {
              _reciveSelectedImages(context);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(
                  0.8, 0.0), // 10% of the width, so there are ten blinds.
              colors: <Color>[
                Color(0xff606060),
                Color(0xff295f6e),
                Color(0xffd81a60)
              ], // red to yellow
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: GlassContainer(
                  width: MediaQuery.of(context).size.width - 16,
                  height: MediaQuery.of(context).size.height - 100,
                  isFrostedGlass: true,
                  frostedOpacity: 0.05,
                  blur: 20,
                  elevation: 15,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.60),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.60),
                    ],
                    stops: [0.0, 0.45, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _document_form_key,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'فرم ایجاد مدرک پزشکی',
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                child: DropdownButton<String>(
                                  value: _examTypeString,
                                  //elevation: 5,
                                  style: TextStyle(color: Colors.black),
                                  items: _examTypes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    "لطفا نوع آزمایش را انتخاب کنید",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _examTypeString = value as String;
                                    });
                                  },
                                ),
                              ),
                              new SizedBox(height: 20.0),
                              _TextReciver(
                                'نام',
                                "name",
                                TextInputAction.next,
                                TextInputType.text,
                                _patientNameFocusNode,
                                _patientLastNameFocusNode,
                              ),
                              new SizedBox(height: 15.0),
                              _TextReciver(
                                "نام خانوادگی",
                                "last_name",
                                TextInputAction.next,
                                TextInputType.text,
                                _patientLastNameFocusNode,
                                _examDoctorNameFocusNode,
                              ),
                              new SizedBox(height: 15.0),
                              _TextReciver(
                                "نام دکتر",
                                "doctor_name",
                                TextInputAction.next,
                                TextInputType.text,
                                _examDoctorNameFocusNode,
                                _examReasonFocusNode,
                              ),
                              new SizedBox(height: 15.0),
                              _TextReciver(
                                "دلیل مراجعه",
                                "reason",
                                TextInputAction.next,
                                TextInputType.text,
                                _examReasonFocusNode,
                                _examLabNameFocusNode,
                              ),
                              new SizedBox(height: 15.0),
                              _TextReciver(
                                "نام آزمایشگاه",
                                "lab_name",
                                TextInputAction.done,
                                TextInputType.text,
                                _examLabNameFocusNode,
                                _examLabNameFocusNode,
                              ),
                              new SizedBox(height: 15.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FlatButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.blue,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    onPressed: () async {
                                      Jalali? picked =
                                          await showPersianDatePicker(
                                        context: context,
                                        initialDate: Jalali.now(),
                                        firstDate: Jalali(1300, 1),
                                        lastDate: Jalali.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          date_label =
                                              picked.formatCompactDate();
                                          map["date"] = date_label;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "تاریخ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(date_label,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  )
                                ],
                              ),
                              !_is_edit
                                  ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: importDocMediaWidget())
                                  : SizedBox(
                                      height: 30,
                                    ),
                              Container(
                                height: 50.0,
                                margin: EdgeInsets.all(10),
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_is_edit) {
                                      _editDocument(map);
                                      _onLoading();
                                    } else {
                                      _pushDocumentToServer(context, map,
                                          _recivedDocImages as List<Asset>);
                                      _onLoading();
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(80.0)),
                                  padding: EdgeInsets.all(0.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff374ABE),
                                            Color(0xff64B6FF)
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: 250.0, minHeight: 50.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'ارسال',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
