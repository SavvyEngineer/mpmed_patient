import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/doctors/provider/doctor_provider.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:mpmed_patient/one_question/provider/one_questions_provider.dart';
import 'package:provider/provider.dart';

class OneQuestionImportForm extends StatefulWidget {
  static const String routeName = '/one_question_import_form';

  @override
  State<OneQuestionImportForm> createState() => _OneQuestionImportFormState();
}

class _OneQuestionImportFormState extends State<OneQuestionImportForm> {
  late Future _doctorsListFuture;
  bool _isInit = true;
  String _selected_doctor_id = '';
  String _user_ref_id = '';
  String _selected_doctor_name = '';
  String _question_content = '';
  String _doctor_notif_token = '';
  bool _is_doctor_selected = false;
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  Future _obtainDoctorsListFuture() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    return Provider.of<DoctorProvider>(context, listen: false)
        .fetchDoctorsList();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final Map recivedMap =
            ModalRoute.of(context)!.settings.arguments as Map;
        _user_ref_id = recivedMap['user_ref_id'];
      }
      _doctorsListFuture = _obtainDoctorsListFuture();
    }
    super.didChangeDependencies();
  }

  _submit_question() async {
    EasyLoading.show(status: 'ارسال سوال شما!');
    print('$_user_ref_id , $_selected_doctor_id, $_question_content');
    await Provider.of<OneQuestionsProvider>(context, listen: false)
        .createQuestion(_user_ref_id, _selected_doctor_id, _question_content,
            DateTime.now().microsecondsSinceEpoch.toString())
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToDoc(
              _doctor_notif_token,
              "یک سؤال جدید",
              'بیمار ${userData['name']} ${userData['lastName']} یک سوال جدید برای شما ارسال کرده است',
              "question_screen", {
        'user_ref_id': userData['national_code'],
        'user_full_name': '${userData['name']} ${userData['lastName']}',
        'user_birth_date': userData['birthDate'],
        'notif_token': userData['notif_token'],
      }).then((value) {
        Navigator.of(context).pop();
        EasyLoading.dismiss();
        EasyLoading.showSuccess('سوال با موفقیت ارسال شد!');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'فقط یه سوال دارم',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: RefreshIndicator(
                      onRefresh: _obtainDoctorsListFuture,
                      child: FutureBuilder(
                        future: _doctorsListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.error != null) {
                              return Center(
                                child: Text('An error occured'),
                              );
                            } else {
                              return _is_doctor_selected
                                  ? Center(
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
                                      height: 170,
                                      width: MediaQuery.of(context).size.width -
                                          16,
                                      child: Center(
                                        child: Text(
                                            "ارسال سوال به دکتر $_selected_doctor_name",
                                            style: TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white)),
                                      ),
                                    ))
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        height: 270,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                16,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Consumer<DoctorProvider>(
                                              builder:
                                                  (context, doctorsData,
                                                          child) =>
                                                      Column(
                                                        children: [
                                                          Text(
                                                            'لطفآ پزشک مورد نظرتان را انتخاب کنید',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Container(
                                                            height: 180,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                16,
                                                            child: ListView
                                                                .builder(
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    itemCount: doctorsData
                                                                        .getDoctorsList
                                                                        .length,
                                                                    itemBuilder:
                                                                        (cxt,
                                                                            index) {
                                                                      return GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _doctor_notif_token = doctorsData.getDoctorsList[index].notifToken.toString();
                                                                              _is_doctor_selected = true;
                                                                              _selected_doctor_id = doctorsData.getDoctorsList[index].nationalCode.toString();
                                                                              _selected_doctor_name = '${doctorsData.getDoctorsList[index].name} ${doctorsData.getDoctorsList[index].lastname}';
                                                                            });
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
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
                                                                                stops: [
                                                                                  0.0,
                                                                                  0.45,
                                                                                  0.55,
                                                                                  1.0
                                                                                ],
                                                                                begin: Alignment.topLeft,
                                                                                end: Alignment.bottomRight,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(25.0),
                                                                              height: 170,
                                                                              width: MediaQuery.of(context).size.width / 2.5,
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Expanded(
                                                                                    flex: 4,
                                                                                    child: CircleAvatar(
                                                                                      radius: 31,
                                                                                      backgroundColor: Colors.transparent,
                                                                                      backgroundImage: NetworkImage(doctorsData.getDoctorsList[index].profilePic.toString()),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                                                                    child: Divider(),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: FittedBox(
                                                                                      fit: BoxFit.scaleDown,
                                                                                      child: Text('${doctorsData.getDoctorsList[index].name} ${doctorsData.getDoctorsList[index].lastname}', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w700)),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: FittedBox(
                                                                                      fit: BoxFit.scaleDown,
                                                                                      child: Text(doctorsData.getDoctorsList[index].specialty.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                                                                      child: FittedBox(
                                                                                        fit: BoxFit.scaleDown,
                                                                                        child: Text('${doctorsData.getDoctorsList[index].wstate} ${doctorsData.getDoctorsList[index].wcity}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ));
                                                                    }),
                                                          ),
                                                        ],
                                                      )),
                                        ),
                                      ),
                                    );
                            }
                          }
                        },
                      )),
                ),
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
                  height: 270,
                  width: MediaQuery.of(context).size.width - 16,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                          child: TextFormField(
                        textAlign: TextAlign.start,
                        style:
                            new TextStyle(fontSize: 14.0, color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          _question_content = value;
                        },
                        maxLines: 6,
                        maxLength: 400,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: 'سوال شما',
                            alignLabelWithHint: true,
                            hintText: 'لطفا سوال خود را وارد کنید',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 14.0,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      )),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      _submit_question();
                    },
                    child: Text('ارسال'))
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
