import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_patient/appbar/universal_app_bar.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/widget/document_item.dart';
import 'package:mpmed_patient/documents/widget/empty_docs_widget.dart';
import 'package:mpmed_patient/helper/get_data_from_ls.dart';
import 'package:mpmed_patient/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import 'document_import_form.dart';

class DocumentsScreen extends StatefulWidget {
  static const String routeName = '/documents';

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  var _isInit = true;
  var _isLoading = true;
  late Future _documentsListFuture;
  int examTypeIndex = 0;
  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  final _advancedDrawerController = AdvancedDrawerController();
  GlobalKey<ScaffoldState> _documentsListscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Map map =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      examTypeIndex = map['exam_type_index'];
      _documentsListFuture = fetchDataFromServer();
    }
    _isInit = false;
  }

  Future<void> fetchDataFromServer() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    print(userData['national_code'].toString());
    await Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetDocuments(
            userData['national_code'].toString(), examTypeIndex);
  }

  Future<void> _refreshDocuments(BuildContext context) async {
    await Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetDocuments(
            userData['national_code'].toString(), examTypeIndex);
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
                'مدارک پزشکی شما',
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
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
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
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.only(
                                    //         left: 8, right: 8),
                                    //     child: ClipRRect(
                                    //       borderRadius:
                                    //           BorderRadius.circular(15),
                                    //       child: Card(
                                    //           elevation: 15,
                                    //           child: Container(
                                    //             child: StaggeredGridView
                                    //                 .countBuilder(
                                    //               itemCount: documentsData
                                    //                   .usersWithDocument.length,
                                    //               crossAxisCount: 8,
                                    //               itemBuilder:
                                    //                   (BuildContext context,
                                    //                           int index) =>
                                    //                       FittedBox(
                                    //                 fit: BoxFit.scaleDown,
                                    //                 child: FlatButton(
                                    //                     shape: RoundedRectangleBorder(
                                    //                         side: BorderSide(
                                    //                             color:
                                    //                                 Colors.blue,
                                    //                             width: 1,
                                    //                             style:
                                    //                                 BorderStyle
                                    //                                     .solid),
                                    //                         borderRadius:
                                    //                             BorderRadius
                                    //                                 .circular(
                                    //                                     50)),
                                    //                     onPressed: () {
                                    //                       documentsData.runFilter(
                                    //                           documentsData
                                    //                               .usersWithDocument[
                                    //                                   index]
                                    //                               .user_id);
                                    //                     },
                                    //                     child: Row(
                                    //                       children: [
                                    //                         IconButton(
                                    //                             onPressed:
                                    //                                 () {},
                                    //                             icon: Icon(Icons
                                    //                                 .cancel)),
                                    //                         Text(
                                    //                             '${documentsData.usersWithDocument[index].name} ${documentsData.usersWithDocument[index].last_name}'),
                                    //                       ],
                                    //                     )),
                                    //               ),
                                    //               staggeredTileBuilder: (int
                                    //                       index) =>
                                    //                   new StaggeredTile.fit(2),
                                    //               mainAxisSpacing: 8.0,
                                    //               crossAxisSpacing: 8.0,
                                    //             ),
                                    //           )),
                                    //     ),
                                    //   ),
                                    // ),
                                    Expanded(
                                      flex: 7,
                                      child: documentsData
                                                  .getDocuments.length ==
                                              0
                                          ? empty_docs_widget('جای مدارکت خالیه')
                                          : SafeArea(
                                              child: documentsData
                                                          .getDocuments.length <
                                                      1
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : ListView.builder(
                                                      itemCount: documentsData
                                                          .getDocuments.length,
                                                      itemBuilder: (_, i) => DocumenetItem(
                                                          documentsData
                                                              .getDocuments[i]
                                                              .id,
                                                          documentsData
                                                              .getDocuments[i]
                                                              .reason,
                                                          documentsData
                                                              .getDocuments[i]
                                                              .doctorName,
                                                          documentsData
                                                              .getDocuments[i]
                                                              .date,
                                                          documentsData
                                                              .getDocuments
                                                              .firstWhere((element) =>
                                                                  element.id ==
                                                                  documentsData
                                                                      .getDocuments[
                                                                          i]
                                                                      .id)
                                                              .toJson(),
                                                          documentsData
                                                              .getDocumentsMedia
                                                              .where((element) =>
                                                                  element
                                                                      .docId ==
                                                                  documentsData
                                                                      .getDocuments[
                                                                          i]
                                                                      .id)
                                                              .toList(),
                                                          false),
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
              label: Text(
                "مدارکتو اینجا بزار!",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(DocumentImportForm.routeName);
              },
            ),
          ),
        ]));
  }
}
