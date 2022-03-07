import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_patient/appbar/universal_app_bar.dart';
import 'package:mpmed_patient/documents/widget/empty_docs_widget.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/notification/notification_bloc.dart';
import 'package:mpmed_patient/one_question/provider/one_questions_provider.dart';
import 'package:mpmed_patient/one_question/screen/one_question_form.dart';
import 'package:mpmed_patient/one_question/screen/one_question_item.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class OneQuestionHome extends StatefulWidget {
  static const String routeName = '/one_question_home';
  @override
  _OneQuestionHomeState createState() => _OneQuestionHomeState();
}

class _OneQuestionHomeState extends State<OneQuestionHome> {
  GlobalKey<ScaffoldState> _usersListQuestionscaffoldKey =
      GlobalKey<ScaffoldState>();

  final _advancedDrawerController = AdvancedDrawerController();
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  late Stream<LocalNotification> _notificationsStream;

  late Future _questionUserListFuture;

  Future _obtainQuestionUsersList() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    return await Provider.of<OneQuestionsProvider>(context, listen: false)
        .fetchOneQuestionUsers(userData['national_code'].toString());
  }

  @override
  void initState() {
    super.initState();
    _questionUserListFuture = _obtainQuestionUsersList();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainQuestionUsersList();
    });
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
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
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment
                    .bottomRight, // 10% of the width, so there are ten blinds.
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
            appBar: UniversalRoundedAppBar(
              height: 100,
              uniKey: _usersListQuestionscaffoldKey,
              advancedDrawerController: _advancedDrawerController,
              isHome: false,
              headerWidget: Text(
                'سوالات شما',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _obtainQuestionUsersList,
              child: FutureBuilder(
                  future: _questionUserListFuture,
                  builder: (context, dataSnapShot) {
                    if (dataSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (dataSnapShot.error != null) {
                        return Center(child: Text('An error occured'));
                      } else {
                        return Consumer<OneQuestionsProvider>(
                            builder: (context, questionsUsersData, child) =>
                                Column(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Center(
                                          child: TextField(
                                              onChanged: (keyChanged) {
                                                if (keyChanged == '') {
                                                  _obtainQuestionUsersList();
                                                } else {
                                                  questionsUsersData
                                                      .runFilterOnParticipants(
                                                          keyChanged);
                                                }
                                              },
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.black38,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)))),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: questionsUsersData
                                                      .getOneQuestionUsers
                                                      .length ==
                                                  0
                                              ? empty_docs_widget(
                                                  'هنوز سوال نپرسیدی')
                                              : StaggeredGridView.countBuilder(
                                                  itemCount: questionsUsersData
                                                      .getOneQuestionUsers
                                                      .length,
                                                  crossAxisCount: 4,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          InkWell(
                                                    onTap: () {
                                                      /////////////////////////////////////////////OPEN Question Item
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              QuestionItemScreen
                                                                  .routeName,
                                                              arguments: {
                                                            'user_ref_id':
                                                                questionsUsersData
                                                                    .getOneQuestionUsers[
                                                                        index]
                                                                    .nationalCode,
                                                            'user_full_name':
                                                                '${questionsUsersData.getOneQuestionUsers[index].name} ${questionsUsersData.getOneQuestionUsers[index].lastName}',
                                                            'user_speciality':
                                                                questionsUsersData
                                                                    .getOneQuestionUsers[
                                                                        index]
                                                                    .specialty,
                                                            'notif_token':
                                                                questionsUsersData
                                                                    .getOneQuestionUsers[
                                                                        index]
                                                                    .notifToken
                                                          });
                                                    },
                                                    child: GlassContainer(
                                                      isFrostedGlass: true,
                                                      frostedOpacity: 0.05,
                                                      blur: 20,
                                                      elevation: 15,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.25),
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.05),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderGradient:
                                                          LinearGradient(
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.60),
                                                          Colors.white
                                                              .withOpacity(0.0),
                                                          Colors.white
                                                              .withOpacity(0.0),
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.60),
                                                        ],
                                                        stops: [
                                                          0.0,
                                                          0.45,
                                                          0.55,
                                                          1.0
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      height: 130,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
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
                                                              backgroundImage: NetworkImage(
                                                                  questionsUsersData
                                                                      .getOneQuestionUsers[
                                                                          index]
                                                                      .profile_pic
                                                                      .toString()),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                '${questionsUsersData.getOneQuestionUsers[index].name} ${questionsUsersData.getOneQuestionUsers[index].lastName}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets.all(
                                                          //           8.0),
                                                          //   child: Text(questionsUsersData
                                                          //       .getQuestionUsersData[
                                                          //           index]
                                                          //       .birthDate
                                                          //       .toString()),
                                                          // ),
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
                  }),
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: Text(
                "سوال دارم !",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(OneQuestionImportForm.routeName,
                    arguments: {
                      'user_ref_id': userData['national_code'].toString()
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
