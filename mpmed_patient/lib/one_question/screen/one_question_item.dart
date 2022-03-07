import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/notification/notification_bloc.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:mpmed_patient/one_question/provider/one_questions_provider.dart';
import 'package:provider/provider.dart';

class QuestionItemScreen extends StatefulWidget {
  static const String routeName = '/question_item_screen';

  @override
  QuestionItemScreenState createState() => QuestionItemScreenState();
}

class QuestionItemScreenState extends State<QuestionItemScreen> {
  Future _questionsListFuture = null as Future;
  GetDataFromLs getDataFromLs = new GetDataFromLs();

  List<types.Message> _messages = [];
  String? user_refId;
  String? userFullName;
  String? user_speciality;
  String? notifToken;

  late Stream<LocalNotification> _notificationsStream;

  bool _isInit = true;

  // final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};
  var _user;

  _getNtcodeFromLS() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    final arguments = ModalRoute.of(context)!.settings.arguments;
    Map recivedData;

    if (arguments.runtimeType.toString() !=
        '_InternalLinkedHashMap<String, String?>') {
      recivedData = json.decode(arguments.toString());
    } else {
      recivedData = arguments as Map;
    }
    user_refId = recivedData['user_ref_id'];
    userFullName = recivedData['user_full_name'];
    user_speciality = recivedData['user_speciality'];
    notifToken = recivedData['notif_token'];
    _questionsListFuture = _obtainQuestionsListFuture();
    _user = types.User(
      id: userData['national_code'].toString(),
    );
  }

  @override
  void initState() {
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainQuestionsListFuture();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _getNtcodeFromLS();
    }
    _isInit = false;
  }

  Future _obtainQuestionsListFuture() {
    return Provider.of<OneQuestionsProvider>(context, listen: false)
        .fetchQuestions(
            userData['national_code'].toString(), user_refId.toString())
        .then((_) async {
      final questionData =
          Provider.of<OneQuestionsProvider>(context, listen: false);
      await _setQuestions(questionData);
    });
  }

  Future<void> _setQuestions(OneQuestionsProvider questionData) async {
    var author;
    List<OneQuestionModel> _questionsList =
        Provider.of<OneQuestionsProvider>(context, listen: false)
            .getOneQuestionItems;

    _questionsList.forEach((element) {
      if (element.userAnswer == 1) {
        author = _user;
      } else {
        author = types.User(
          id: user_refId.toString(),
        );
      }
      final textMessage = types.TextMessage(
          author: author,
          id: element.questionId.toString(),
          //createdAt: int.parse(element.time as String),
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
    await Provider.of<OneQuestionsProvider>(context, listen: false)
        .createQuestion(userData['national_code'].toString(),
            user_refId.toString(), message.text.toString(), StringId.toString())
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToDoc(notifToken.toString(), "یک سؤال جدید",
              'بیمار ${userData['name']} ${userData['lastName']} یک سوال جدید برای شما ارسال کرده است', "question_screen", {
        'user_ref_id': userData['national_code'],
        'user_full_name': '${userData['name']} ${userData['lastName']}',
        'user_birth_date': userData['birthDate'],
        'notif_token': userData['notif_token'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: double.infinity,
                  color: Colors.green,
                  child: Stack(
                    children: [
                      Positioned(
                          left: 0,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                  backgroundColor: Colors.lightGreen,
                                  child: Icon(Icons.arrow_back)),
                            ),
                          )),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(userFullName.toString(),
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(user_speciality.toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 8,
                child: SafeArea(
                  bottom: false,
                  child: FutureBuilder(
                    future: _questionsListFuture,
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
                          return Chat(
                            messages: _messages,
                            onSendPressed: _handleSendPressed,
                            user: _user,
                            l10n: const ChatL10nEn(
                                inputPlaceholder: 'پاسخ شما',
                                attachmentButtonAccessibilityLabel: '',
                                emptyChatPlaceholder:
                                    'برای شما پیامی ارسال نشده است',
                                fileButtonAccessibilityLabel: '',
                                sendButtonAccessibilityLabel: ''),
                          );
                        }
                      }
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
