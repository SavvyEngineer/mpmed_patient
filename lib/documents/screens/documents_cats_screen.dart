import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:mobx/mobx.dart';
import 'package:mpmed_patient/appbar/universal_app_bar.dart';
import 'package:mpmed_patient/documents/screens/document_import_form.dart';
import 'package:mpmed_patient/documents/screens/documents_screen.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';

class DocumentsCatsScreen extends StatefulWidget {
  static const String routeName = '/documents_categories';

  @override
  _DocumentsCatsScreenState createState() => _DocumentsCatsScreenState();
}

class _DocumentsCatsScreenState extends State<DocumentsCatsScreen> {
  GlobalKey<ScaffoldState> _documentsHomeScreenScaffoldKey =
      GlobalKey<ScaffoldState>();

  final _advancedDrawerController = AdvancedDrawerController();

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
            backgroundColor: Colors.white,
            appBar: UniversalRoundedAppBar(
              height: 100,
              uniKey: _documentsHomeScreenScaffoldKey,
              advancedDrawerController: _advancedDrawerController,
              isHome: false,
              headerWidget: Text(
                'مدارک پزشکی شما',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(DocumentsScreen.routeName,
                          arguments: {"exam_type_index": 0});
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
                                    image: AssetImage('assets/img/test_bg.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                DocumentsScreen.routeName,
                                arguments: {"exam_type_index": 1});
                          },
                          child: Card(
                            color: Color(0xff295f6e),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Container(
                              height: MediaQuery.of(context).size.height / 6,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/img/tasvirbardari_bg.png'),
                                      fit: BoxFit.scaleDown)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                DocumentsScreen.routeName,
                                arguments: {"exam_type_index": 2});
                          },
                          child: Card(
                            color: Color(0xff295f6e),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Container(
                              height: MediaQuery.of(context).size.height / 6,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/img/patalogy_bg.png'),
                                      fit: BoxFit.scaleDown)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(DocumentsScreen.routeName,
                          arguments: {"exam_type_index": 3});
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
                                        'assets/img/sonography_bg.png'),
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
                      Navigator.of(context).pushNamed(DocumentsScreen.routeName,
                          arguments: {"exam_type_index": 4});
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
                                        'assets/img/ghalb_o_orugh_bg.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: Text("مدارکتو اینجا بزار!",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
              onPressed: () {
                Navigator.of(context).pushNamed(DocumentImportForm.routeName);
              },
            ),
          )
        ],
      ),
    );
  }
}
