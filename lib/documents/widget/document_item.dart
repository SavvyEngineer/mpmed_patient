import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_patient/doctors/provider/doctor_provider.dart';
import 'package:mpmed_patient/documents/pdf_generator/pdf_generator.dart';
import 'package:mpmed_patient/documents/pdf_generator/pdf_screen.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/screens/document_import_form.dart';
import 'package:mpmed_patient/documents/screens/document_item_screen.dart';
import 'package:mpmed_patient/documents/screens/send_multiple_docs.dart';
import 'package:mpmed_patient/documents/widget/image_slider_widget.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:provider/provider.dart';

class DocumenetItem extends StatefulWidget {
  final int id;
  final String reason;
  final String doctor_name;
  final String date;
  final Map documentData;
  final List<DocumentMediaModel> documentMediaData;
  static List<String> selected_documents = [];
  final bool _is_multiple;

  DocumenetItem(this.id, this.reason, this.doctor_name, this.date,
      this.documentData, this.documentMediaData, this._is_multiple);

  @override
  State<DocumenetItem> createState() => _DocumenetItemState();

  static List<String> get getSelectedDocuments {
    return [...selected_documents];
  }
}

class _DocumenetItemState extends State<DocumenetItem> {
  late Future _doctorsListFuture;
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  bool _is_selected = false;

  bool _giving_access_loading = false;

  Future _obtainDoctorsListFuture() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    return await Provider.of<DoctorProvider>(context, listen: false)
        .fetchDoctorsList();
  }

  Future<void> _giveAccess_to_doctor(String doctorNtcode, String notif_token,
      String userNtcode, String docId) async {
    EasyLoading.show(status: 'در حال ارسال مدرک پزشکی شما');
    await Provider.of<DocumentsProvider>(context, listen: false)
        .giveAccess(doctorNtcode, userNtcode, docId)
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToDoc(
              notif_token,
              "مدرک پزشکی جدید",
              'بیمار ${userData['name']} ${userData['lastName']} مدرک پزشکی برای شما ارسال کرده است ',
              "documents_screen", {
        'userId': userNtcode,
        'doctorNtcode': doctorNtcode
      }).then((value) {
        EasyLoading.dismiss();
        Navigator.of(context).pop();
        EasyLoading.showSuccess('مدرک پزشکی شما با موفقیت ارسال شد');
      });
    });
  }

  Future<void> _createPdf(String docId) async {
    PdfGenerator pdfGenerator = new PdfGenerator();
    await pdfGenerator
        .generatePDF(context, widget.documentData, widget.documentMediaData)
        .then((value) {
      EasyLoading.dismiss();
    });
  }

  Future<void> _deleteDocument(String docId) async {
    EasyLoading.show(status: 'درحال پاک کردن مدرک پزشکی شما');
    await Provider.of<DocumentsProvider>(context, listen: false)
        .deleteDocument(docId, userData['national_code'],
            widget.documentData['exam_type_index'])
        .then((value) {
      EasyLoading.dismiss();
      EasyLoading.showSuccess('مدرک پزشکی با موفقیت حذف شد');
    });
  }

  @override
  void initState() {
    super.initState();
    _doctorsListFuture = _obtainDoctorsListFuture();
  }

  showDeleteAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("لغو"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("حذف"),
      onPressed: () {
        Navigator.of(context).pop();
        _deleteDocument(widget.id.toString());
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("هشدار"),
      content: Text("آیا شما از حذف کردن مدرکتان اطمینان دارید ؟"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showAlertDialog(BuildContext context, String docId, String userNtcode) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'اشتراک گذاری مدرک پزشکی شما',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ),
                    SizedBox(
                        width: 320.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _doctorsListInAlertDialog(
                                    context, docId, userNtcode);
                              },
                              child: Text(
                                "پزشکان",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: const Color(0xFF1BC0C5),
                            ),
                            RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                EasyLoading.show(
                                    status: 'درحال آماده سازی فایل PDF...');
                                _createPdf(docId);
                              },
                              child: Text(
                                "ساخت pdf",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: const Color(0xFF1BC0C5),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          );
        });
  }

  _doctorsListInAlertDialog(
      BuildContext context, String docId, String userNtcode) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Stack(children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment
                      .bottomLeft, // 10% of the width, so there are ten blinds.
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
                child: Column(
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: _doctorsListFuture,
                        builder: (context, dataSnapShot) {
                          if (dataSnapShot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (dataSnapShot.error != null) {
                              return Center(
                                child: Text('An error occured'),
                              );
                            } else {
                              return _giving_access_loading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Consumer<DoctorProvider>(
                                      builder: (context, doctorsData, child) =>
                                          Column(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: TextField(
                                                        onChanged:
                                                            (keyChanged) {
                                                          if (keyChanged ==
                                                              '') {
                                                            doctorsData
                                                                .fetchDoctorsList();
                                                          } else {
                                                            doctorsData
                                                                .runFilter(
                                                                    keyChanged);
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.search,
                                                                  color: Colors
                                                                      .black38,
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .white,
                                                                        width:
                                                                            1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25)),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .white,
                                                                        width:
                                                                            1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25)))),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: StaggeredGridView
                                                    .countBuilder(
                                                  itemCount: doctorsData
                                                      .getDoctorsList.length,
                                                  crossAxisCount: 4,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          GlassContainer(
                                                    isFrostedGlass: true,
                                                    frostedOpacity: 0.05,
                                                    blur: 20,
                                                    elevation: 15,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.25),
                                                        Colors.white
                                                            .withOpacity(0.05),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderGradient:
                                                        LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.60),
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                        Colors.white
                                                            .withOpacity(0.60),
                                                      ],
                                                      stops: [
                                                        0.0,
                                                        0.45,
                                                        0.55,
                                                        1.0
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    height: 170,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _giveAccess_to_doctor(
                                                            doctorsData
                                                                .getDoctorsList[
                                                                    index]
                                                                .nationalCode
                                                                .toString(),
                                                            doctorsData
                                                                .getDoctorsList[
                                                                    index]
                                                                .notifToken
                                                                .toString(),
                                                            userNtcode,
                                                            docId);
                                                        setState(() {
                                                          _giving_access_loading =
                                                              true;
                                                        });
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: CircleAvatar(
                                                              radius: 31,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              backgroundImage:
                                                                  NetworkImage(doctorsData
                                                                      .getDoctorsList[
                                                                          index]
                                                                      .profilePic
                                                                      .toString()),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    right: 8),
                                                            child: Divider(),
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                                '${doctorsData.getDoctorsList[index].name} ${doctorsData.getDoctorsList[index].lastname}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                                doctorsData
                                                                    .getDoctorsList[
                                                                        index]
                                                                    .specialty
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    right: 8),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                  '${doctorsData.getDoctorsList[index].wstate} ${doctorsData.getDoctorsList[index].wcity}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  staggeredTileBuilder: (int
                                                          index) =>
                                                      new StaggeredTile.fit(2),
                                                  mainAxisSpacing: 8.0,
                                                  crossAxisSpacing: 8.0,
                                                ),
                                              ),
                                            ],
                                          ));
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        });
  }

  _showPopupMenu(Offset offset, BuildContext context, String docId,
      String userNtcode) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: Text("اشتراک گذاری"),
          onTap: () {
            Future.delayed(const Duration(seconds: 0), () {
              _showAlertDialog(
                context,
                docId,
                userNtcode,
              );
            });
          },
        ),
        PopupMenuItem(
          value: 2,
          child: Text("ویرایش"),
          onTap: () {
            Future.delayed(const Duration(seconds: 0), () {
              Navigator.of(context).pushNamed(DocumentImportForm.routeName,
                  arguments: {'DocumentData': widget.documentData});
            });
          },
        ),
        PopupMenuItem(
          value: 3,
          child: Text("حذف"),
          onTap: () {
            Future.delayed(const Duration(seconds: 0), () {
              showDeleteAlertDialog(context);
            });
          },
        ),
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final mediaLinksData =
        Provider.of<DocumentsProvider>(context, listen: false)
            .getDocumentsMedia;

    return Container(
      height: 220,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8, left: 10, right: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            DocumentItemScreen.routeName,
            arguments: {
              'itemId': widget.id,
              'page_index': 0,
              'exam_type_index': widget.documentData['exam_type_index']
            } as Map<String, dynamic>,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: GlassContainer(
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
                height: 130,
                width: mediaQuery.size.width,
                child: Container(
                  margin: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: Stack(children: [
                    Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.reason,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: 180,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.doctor_name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                              Text(
                                widget.date,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTapUp: (TapUpDetails details) {
                          _showPopupMenu(
                              details.globalPosition,
                              context,
                              widget.id.toString(),
                              userData['national_code'].toString());
                        },
                        child: Container(
                            child: !widget._is_multiple
                                ? Icon(
                                    Icons.more_vert,
                                    color: Colors.amber,
                                    size: 31,
                                  )
                                : Checkbox(
                                    value: _is_selected,
                                    onChanged: (value) {
                                      _is_selected = value!;
                                      if (_is_selected) {
                                        DocumenetItem.selected_documents
                                            .add(widget.id.toString());
                                        setState(() {
                                          _is_selected = true;
                                        });
                                      } else {
                                        setState(() {
                                          _is_selected = false;
                                        });
                                        DocumenetItem.selected_documents
                                            .remove(widget.id.toString());
                                      }
                                    })),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: image_slider_widget(
                    id: widget.id, mediaData: mediaLinksData))
          ],
        ),
      ),
    );
  }
}
