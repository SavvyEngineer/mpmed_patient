import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/authOtp/theme.dart';
import 'package:mpmed_patient/doctors/provider/doctor_provider.dart';
import 'package:mpmed_patient/documents/Review/model/review_model.dart';
import 'package:mpmed_patient/documents/Review/providers/review_provider.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/screens/full_screen_image_page.dart';
import 'package:mpmed_patient/documents/widget/image_slider_widget.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/notification/notification_bloc.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DocumentItemScreen extends StatefulWidget {
  static const String routeName = '/document_item';

  @override
  _DocumentItemScreenState createState() => _DocumentItemScreenState();
}

class _DocumentItemScreenState extends State<DocumentItemScreen> {
  double _crossAxisSpacing = 4, _mainAxisSpacing = 1, _aspectRatio = 3;

  late Future? _reviewsListFuture;
  late Future? _doctorsListFuture;
  Future _documentsListFuture = null as Future;
  bool _isInit = true;
  bool _is_review_initialized = false;
  bool _is_review_history = false;
  bool _from_notif = false;
  String selected_doctor_ntcode = '';
  String doctorNotifToken = "";
  late Stream<LocalNotification> _notificationsStream;
  late DocumentModel documentElement;
  late DocumentsProvider documentData;

  int _crossAxisCount = 2;

  List<types.Message> _messages = [];
  int? id;
  int? _examTypeIndex;

  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};
  var _user;
  var _currentIndex = 0;

  @override
  void initState() {
    _documentsListFuture = _obtainDocumentsFuture();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainReviewsListFuture();
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     _documentsListFuture = _obtainDocumentsFuture();
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  Future _obtainDocumentsFuture() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
    _user = types.User(
      id: userData['national_code'].toString(),
    );

    final arguments = ModalRoute.of(context)!.settings.arguments;

    Map recivedData;

    setState(() {
      if (arguments.runtimeType.toString() != 'String') {
        recivedData = arguments as Map;
      } else {
        recivedData = json.decode(arguments.toString());
        selected_doctor_ntcode = recivedData['doctor_ntcode'].toString();
        doctorNotifToken = recivedData['doc_notif_token'].toString();
        _is_review_initialized = true;
      }

      id = recivedData['itemId'];
      _currentIndex = recivedData['page_index'];
      _examTypeIndex = recivedData['exam_type_index'];
    });
    _reviewsListFuture = _obtainReviewsListFuture();
    _doctorsListFuture = _obtainDoctorsListFuture();
    return Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetDocuments(userData['national_code'], _examTypeIndex as int);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _getNtcodeFromLS();
  // }

  Future _obtainReviewsListFuture() async {
    print(
        'review Args$doctorNotifToken ----- $id ----- $selected_doctor_ntcode');
    await Provider.of<DoctorProvider>(context, listen: false)
        .fetchAndSetAllReviews(id.toString())
        .then((value) => _is_review_history = value);
    return Provider.of<ReviewProvider>(context, listen: false)
        .fetchAndSetReview(selected_doctor_ntcode, id.toString())
        .then((_) async {
      documentData =
          await Provider.of<DocumentsProvider>(context, listen: false);
      await _setReviews(documentData);
    });
  }

  Future _obtainDoctorsListFuture() async {
    return Provider.of<DoctorProvider>(context, listen: false)
        .fetchDoctorsList();
  }

  Future<void> _setReviews(DocumentsProvider documentData) async {
    List<ReviewModel> _reviewList = [];
    var author;
    _reviewList =
        Provider.of<ReviewProvider>(context, listen: false).getReviews;

    documentElement =
        documentData.getDocuments.firstWhere((element) => element.id == id);
    _messages.clear();

    [
      ...{..._reviewList}
    ].forEach((element) {
      if (element.userAnswer == 1) {
        author = _user;
      } else {
        author = types.User(
          id: '${documentElement.reviewDocNtcode}${documentElement.id}',
        );
      }
      final textMessage = types.TextMessage(
          author: author,
          createdAt: int.parse(element.time.toString()),
          id: element.reviewId.toString(),
          text: element.content.toString(),
          status: types.Status.sent);

      _addMessage(textMessage);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    var status = types.Status.sending;
    final StringId = DateTime.now().millisecondsSinceEpoch;
    var textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: StringId.toString(),
        text: message.text,
        status: status);
    _addMessage(textMessage);
    await Provider.of<ReviewProvider>(context, listen: false)
        .createReview(id.toString(), message.text.toString(),
            selected_doctor_ntcode.toString())
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToDoc(
              doctorNotifToken,
              "پیام جدید",
              'بیمار ${userData['name']} ${userData['lastName']} پیامی جدید برای شما ارسال کرده است ',
              "review_screen", {
        'itemId': id,
        'patient_id': userData['national_code'],
        'page_index': 1
      });
      _messages.remove(textMessage);

      var updatedTextMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: StringId.toString(),
          text: message.text,
          status: types.Status.sent);
      _addMessage(updatedTextMessage);
    });
  }

  String _isReviewedFunc(String doctor_id) {
    String resault = '';

    try {
      List<ReviewModel> reviewList =
          Provider.of<DoctorProvider>(context, listen: false).getReviewList;

      reviewList.forEach((element) {
        if (element.doctorId.toString() == doctor_id.toString()) {
          resault = "بازگشت به مکالمه پیشین";
        } else {
          resault = "شروع مکالمه";
        }
      });
    } catch (e) {
      print('checking is reviewed ${e.toString()}');
    }

    return resault;
  }

  Future<void> _giveAccess_to_doctor(String doctorNtcode, String userNtcode,
      String docId, String notif_token) async {
    await Provider.of<DocumentsProvider>(context, listen: false)
        .giveAccess(doctorNtcode, userNtcode, docId)
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToDoc(
              notif_token,
              "مدرک پزشکی جدید",
              'بیمار ${userData['name']} ${userData['lastName']} مدرک پزشکی برای شما ارسال کرده است ',
              "documents_screen",
              {'userId': userNtcode, 'doctorNtcode': doctorNtcode});
    });
  }

  Future<void> _initializeReviewSystem(
      String doctorNtcode, String notif_token) async {
    await Provider.of<DocumentsProvider>(context, listen: false)
        .checkAccess(doctorNtcode, id.toString())
        .then((value) async {
      if (!value) {
        await _giveAccess_to_doctor(doctorNtcode,
            userData['national_code'].toString(), id.toString(), notif_token);
      }
      setState(() {
        selected_doctor_ntcode = doctorNtcode;
        doctorNotifToken = notif_token;
        _is_review_initialized = true;
      });
      await _obtainReviewsListFuture();
    });
  }

  Widget _doctorsList() {
    return RefreshIndicator(
      onRefresh: _obtainDoctorsListFuture,
      child: FutureBuilder(
        future: _doctorsListFuture,
        builder: (context, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapShot.error != null) {
              return Center(
                child: Text('An error occured'),
              );
            } else {
              return Consumer<DoctorProvider>(
                  builder: (context, doctorsData, child) => Stack(children: [
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
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: TextField(
                                    onChanged: (keyChanged) {
                                      if (keyChanged == '') {
                                        doctorsData.fetchDoctorsList();
                                      } else {
                                        // doctorsData
                                        //     .runFilter(keyChanged);
                                      }
                                    },
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.black38,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(25)))),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: StaggeredGridView.countBuilder(
                                itemCount: doctorsData.getDoctorsList.length,
                                crossAxisCount: 4,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        GlassContainer(
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
                                  height: 170,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: InkWell(
                                    onTap: () {
                                      _initializeReviewSystem(
                                          doctorsData.getDoctorsList[index]
                                              .nationalCode
                                              .toString(),
                                          doctorsData
                                              .getDoctorsList[index].notifToken
                                              .toString());
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircleAvatar(
                                            radius: 31,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: NetworkImage(
                                                doctorsData
                                                    .getDoctorsList[index]
                                                    .profilePic
                                                    .toString()),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Divider(),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                              '${doctorsData.getDoctorsList[index].name} ${doctorsData.getDoctorsList[index].lastname}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                              doctorsData.getDoctorsList[index]
                                                  .specialty
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                                _is_review_history
                                                    ? _isReviewedFunc(
                                                            doctorsData
                                                                .getDoctorsList[
                                                                    index]
                                                                .nationalCode
                                                                .toString())
                                                        .toString()
                                                    : "شروع مکالمه",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: _isReviewedFunc(doctorsData
                                                                    .getDoctorsList[
                                                                        index]
                                                                    .nationalCode
                                                                    .toString())
                                                                .toString() ==
                                                            "شروع مکالمه"
                                                        ? Colors.orange
                                                        : Colors.lime)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                staggeredTileBuilder: (int index) =>
                                    new StaggeredTile.fit(2),
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                              ),
                            ),
                          ],
                        ),
                      ]));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.only(left: 40, top: 8, bottom: 8, right: 40),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.document_scanner), title: Text('مدارک')),
          SalomonBottomBarItem(
              icon: Icon(Icons.chat), title: Text('گفتگو با بیمار'))
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: MyColors.primaryColorLight.withAlpha(20),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: MyColors.primaryColor,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0x44000000),
        elevation: 0,
      ),
      body: _currentIndex == 0
          ? FutureBuilder(
              future: _documentsListFuture,
              builder: (context, dataSnapShot) {
                if (dataSnapShot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (dataSnapShot.error != null) {
                    return Center(
                      child: Text('An error occured'),
                    );
                  } else {
                    return Consumer<DocumentsProvider>(
                      builder: (context, documentData, child) {
                        var documentElement = documentData.getDocuments
                            .firstWhere((element) => element.id == id);
                        return Column(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        FullScreenImageViewer.routeName,
                                        arguments: {
                                          'documentId': documentElement.id,
                                          'documentMediaList':
                                              documentData.getDocumentsMedia
                                        });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        .75,
                                    child: image_slider_widget(
                                      id: documentElement.id,
                                      mediaData: documentData.getDocumentsMedia,
                                      changeDirection: Axis.horizontal,
                                      imageScale: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .75,
                                      is_full_screen: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(),
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                child: GridView.count(
                                  crossAxisCount: _crossAxisCount,
                                  crossAxisSpacing: _crossAxisSpacing,
                                  mainAxisSpacing: _mainAxisSpacing,
                                  childAspectRatio: _aspectRatio,
                                  padding: EdgeInsets.zero,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نام"),
                                        subtitle: Text(documentElement.name),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نام خانوادگی"),
                                        subtitle:
                                            Text(documentElement.lastName),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("تاریخ"),
                                        subtitle: Text(documentElement.date),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 20,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text("پزشک معالج"),
                                            subtitle: Text(
                                                documentElement.doctorName),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("دلیل مراجعه"),
                                        subtitle: Text(documentElement.reason),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("آزمایشگاه"),
                                        subtitle: Text(documentElement.labName),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نوع آزمایش"),
                                        subtitle:
                                            Text(documentElement.examType),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                }
              })
          : ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Card(
                elevation: 15,
                child: FutureBuilder(
                    future: _reviewsListFuture,
                    builder: (context, dataSnapShot) {
                      if (dataSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (dataSnapShot.error != null &&
                            _is_review_history &&
                            _is_review_initialized) {
                          setState(() {
                            _is_review_history = false;
                            _is_review_initialized = false;
                          });
                          return Center(
                            child: Text('An error occured'),
                          );
                        } else {
                          return SafeArea(
                              bottom: false,
                              child: _is_review_initialized
                                  ? Chat(
                                      messages: _messages,
                                      onSendPressed: _handleSendPressed,
                                      user: _user,
                                      l10n: const ChatL10nEn(
                                          inputPlaceholder: 'پاسخ شما',
                                          attachmentButtonAccessibilityLabel:
                                              '',
                                          emptyChatPlaceholder:
                                              'برای شما پیامی ارسال نشده است',
                                          fileButtonAccessibilityLabel: '',
                                          sendButtonAccessibilityLabel: ''))
                                  : _doctorsList());
                        }
                      }
                    } //
                    ),
                // Text("no chat yet"),
              ),
            ),
    );
  }
}
