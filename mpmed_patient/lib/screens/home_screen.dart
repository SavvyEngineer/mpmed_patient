import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:mpmed_patient/appbar/custom_app_bar.dart';
import 'package:mpmed_patient/doctors/screen/doctors_list_screen.dart';
import 'package:mpmed_patient/documents/screens/documents_cats_screen.dart';
import 'package:mpmed_patient/documents/screens/send_multiple_docs.dart';
import 'package:mpmed_patient/notification/fcm_service.dart';
import 'package:mpmed_patient/notification/model/push_notifiication_pojo.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:mpmed_patient/notification/widget/notification_badge.dart';
import 'package:mpmed_patient/one_question/screen/one_question_h_screen.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: true,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
          // NOTICE: Uncomment if you want to add shadow behind the page.
          // Keep in mind that it may cause animation jerks.
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 0.0,
          //   ),
          // ],
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      drawer: AppDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
                floating: true,
                pinned: false,
                delegate: CustomAppBar(
                    height: 120,
                    key: _scaffoldKey,
                    advancedDrawerController: _advancedDrawerController)),
            SliverFillRemaining(
              fillOverscroll: true,
              hasScrollBody: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(DocumentsCatsScreen.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/medical_docs_logo.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(OneQuestionHome.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/one_question_logo.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(SendMultipleDocuments.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/send_doc_logo.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          DoctorsListScreen.routeName,
                          arguments: {'selecting_doctors': false});
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/docs_list_logo.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
