import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_patient/appbar/universal_app_bar.dart';
import 'package:mpmed_patient/doctors/provider/doctor_provider.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class DoctorItemScreen extends StatefulWidget {
  DoctorModel? doctorModel;

  DoctorItemScreen(this.doctorModel);

  @override
  State<DoctorItemScreen> createState() => _DoctorItemScreenState();
}

class _DoctorItemScreenState extends State<DoctorItemScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  late Future _workingHoursFuture;

  GlobalKey<ScaffoldState> _docWdaysScaffoldKey = GlobalKey<ScaffoldState>();

  Future _obtainWorkingHoursFuture() async {
    return Provider.of<DoctorProvider>(context, listen: false)
        .fetchAndSetWorkingHours(widget.doctorModel!.nationalCode.toString());
  }

  @override
  void initState() {
    super.initState();
    _workingHoursFuture = _obtainWorkingHoursFuture();
  }

  List<String> _weekDays = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه'
  ];

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
            extendBodyBehindAppBar: true,
            appBar: UniversalRoundedAppBar(
              height: 100,
              uniKey: _docWdaysScaffoldKey,
              advancedDrawerController: _advancedDrawerController,
              isHome: false,
              headerWidget: Text(
                'اطلاعات پزشک',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3 + 100,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: EdgeInsets.only(bottom: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(
                                widget.doctorModel!.profilePic.toString(),
                              ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            '${widget.doctorModel!.name} ${widget.doctorModel!.lastname}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2,
                          child: RefreshIndicator(
                              onRefresh: _obtainWorkingHoursFuture,
                              child: FutureBuilder(
                                  future: _workingHoursFuture,
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
                                        return Consumer<DoctorProvider>(
                                          builder: (context, doctorsData,
                                                  child) =>
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: doctorsData
                                                              .getWorkingHoursByDay
                                                              .length >
                                                          1
                                                      ? ListView.builder(
                                                          itemCount:
                                                              _weekDays.length,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 8),
                                                              child:
                                                                  GlassContainer(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    30,
                                                                height: 150,
                                                                isFrostedGlass:
                                                                    true,
                                                                frostedOpacity:
                                                                    0.05,
                                                                blur: 20,
                                                                elevation: 15,
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.25),
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.05),
                                                                  ],
                                                                  begin: Alignment
                                                                      .topLeft,
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
                                                                        .withOpacity(
                                                                            0.0),
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.0),
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
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25.0),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      _weekDays[
                                                                          index],
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              21),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8),
                                                                            child:
                                                                                Icon(
                                                                              Icons.access_time,
                                                                              color: Colors.white70,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              doctorsData.getWorkingHoursByDay[index] == 'NA' ? "روزه غیر کاری" : doctorsData.getWorkingHoursByDay[index],
                                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : Center(
                                                          child: GlassContainer(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                30,
                                                            height: 150,
                                                            isFrostedGlass:
                                                                true,
                                                            frostedOpacity:
                                                                0.05,
                                                            blur: 20,
                                                            elevation: 15,
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.25),
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.05),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
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
                                                                    .withOpacity(
                                                                        0.0),
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.0),
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
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25.0),
                                                            child: Center(
                                                              child: Text(
                                                                  'این پزشک ساعت کاری خود را وارد نکرده است',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          ),
                                                        )),
                                        );
                                      }
                                    }
                                  }))),
                      Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              'ساعات کاری',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
