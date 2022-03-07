import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:mpmed_patient/appbar/universal_app_bar.dart';
import 'package:mpmed_patient/doctors/screen/doctors_list_screen.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/widget/document_item.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class SendMultipleDocuments extends StatefulWidget {
  static const String routeName = '/send_multiple_docs';
  static GlobalKey<_SendMultipleDocumentsState> floatingActionButtonKey =
      GlobalKey<_SendMultipleDocumentsState>();

  @override
  _SendMultipleDocumentsState createState() => _SendMultipleDocumentsState();
}

class _SendMultipleDocumentsState extends State<SendMultipleDocuments> {
  late Future _documentsListFuture;
  bool _isInit = true;
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      
      _documentsListFuture = fetchDataFromServer();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  final _advancedDrawerController = AdvancedDrawerController();
  GlobalKey<ScaffoldState> _documentsListscaffoldKey =
      GlobalKey<ScaffoldState>();
      

  Future<void> fetchDataFromServer() async {
    await getDataFromLs.getProfileData().then((value) {
        userData = value;
      });
    await Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetAllDocumentsByNtCode(userData['national_code'].toString())
        .then((_) {
      DocumenetItem.selected_documents = [];
    });
  }

  Future<void> _refreshDocuments(BuildContext context) async {
    await Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetAllDocumentsByNtCode(userData['national_code'].toString());
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
        child: Stack(children: <Widget>[
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
            appBar: UniversalRoundedAppBar(
              height: 100,
              uniKey: _documentsListscaffoldKey,
              advancedDrawerController: _advancedDrawerController,
              isHome: false,
              headerWidget: Text(
                'انتخاب چند مدرک پزشکی',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            body: RefreshIndicator(
                onRefresh: () => _refreshDocuments(context),
                child: FutureBuilder(
                  future: _documentsListFuture,
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
                        return Consumer<DocumentsProvider>(
                            builder: (context, documentsData, child) => Column(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: TextField(
                                              onChanged: (keyChanged) {
                                                if (keyChanged == '') {
                                                  setState(() {
                                                    _refreshDocuments(context);
                                                  });
                                                } else {
                                                  setState(() {
                                                    documentsData
                                                        .runFilter(keyChanged);
                                                  });
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
                                                          borderSide: BorderSide(
                                                              color: Colors.white,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25)),
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
                                      child: SafeArea(
                                        child: ListView.builder(
                                          itemCount:
                                              documentsData.getDocuments.length,
                                          itemBuilder: (_, i) => DocumenetItem(
                                              documentsData.getDocuments[i].id,
                                              documentsData
                                                  .getDocuments[i].reason,
                                              documentsData
                                                  .getDocuments[i].doctorName,
                                              documentsData
                                                  .getDocuments[i].date,
                                              documentsData.getDocuments
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      documentsData
                                                          .getDocuments[i].id)
                                                  .toJson(),
                                              documentsData.getDocumentsMedia
                                                  .where((element) =>
                                                      element.docId ==
                                                      documentsData
                                                          .getDocuments[i].id)
                                                  .toList(),
                                              true),
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                      }
                    }
                  },
                )),
            floatingActionButton: FloatingActionButton.extended(
              key: SendMultipleDocuments.floatingActionButtonKey,
              label: Text('ارسال مدارک',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
              onPressed: () {
                // print(DocumenetItem.getSelectedDocuments.length.toString());
                // DocumenetItem.getSelectedDocuments.forEach((element) {
                //   print(element.toString());
                // });

                Navigator.of(context)
                          .pushNamed(DoctorsListScreen.routeName,arguments: {
                            'selecting_doctors':true
                          });
              },
            ),
          ),
        ]));
  }
}
