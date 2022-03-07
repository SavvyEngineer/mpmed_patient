import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:localstorage/localstorage.dart';

import 'custom_toolbar_shape.dart';

class UniversalRoundedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  double height;
  GlobalKey<ScaffoldState> uniKey;
  AdvancedDrawerController advancedDrawerController;
  bool isHome;
  Widget headerWidget;

  UniversalRoundedAppBar(
      {required this.height,
      required this.uniKey,
      required this.advancedDrawerController,
      required this.headerWidget,
      this.isHome = true});

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("لغو"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("بله"),
      onPressed: () async {
        final LocalStorage storage = new LocalStorage('userData');
        await storage.ready;
        await storage.clear();
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("لطفا توجه کنید"),
      content: Text(
        'آیا واقعاً می خواهید از حساب کاربری خود خارج شوید؟',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
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

  @override
  Widget build(BuildContext context) {
    return new SizedBox.fromSize(
      size: preferredSize,
      child: new LayoutBuilder(builder: (context, constraint) {
        return new Container(
            color: Colors.transparent,
            child: Material(
              color: Colors.transparent,
              elevation: 15,
              child: Stack(fit: StackFit.loose, children: <Widget>[
                Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: height,
                    child: CustomPaint(
                      painter: CustomToolbarShape(lineColor: Colors.white),
                    )),
                Align(
                    alignment: Alignment(0.0, 1.25),
                    child: Container(
                        height: MediaQuery.of(context).size.height / 14.5,
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                            decoration: new BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20.0,
                                  // shadow
                                  spreadRadius: .5,
                                  // set effect of extending the shadow
                                  offset: Offset(
                                    0.0,
                                    5.0,
                                  ),
                                )
                              ],
                            ),
                            child: isHome
                                ? Image.asset(
                                    'assets/img/logo_type.png',
                                    fit: BoxFit.fitWidth,
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                  )
                                : headerWidget))),
                // TextField(
                //     onSubmitted: (submittedText) {},
                //     decoration: InputDecoration(
                //         filled: true,
                //         fillColor: Colors.white,
                //         prefixIcon: Icon(
                //           Icons.search,
                //           color: Colors.black38,
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //             borderSide:
                //                 BorderSide(color: Colors.white, width: 1),
                //             borderRadius: BorderRadius.circular(25)),
                //         enabledBorder: OutlineInputBorder(
                //             borderSide:
                //                 BorderSide(color: Colors.white, width: 1),
                //             borderRadius: BorderRadius.circular(25))))))),
                Align(
                    alignment: Alignment(-0.9, 0.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height / 13,
                        width: MediaQuery.of(context).size.width / 13,
                        child: InkWell(
                          onTap: () {
                            showAlertDialog(context);
                          },
                          child: Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                        ))),
                Align(
                    alignment: Alignment(0.9, 0.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height / 13,
                        width: MediaQuery.of(context).size.width / 13,
                        child: InkWell(
                            onTap: () {
                              // uniKey.currentState!.openDrawer();
                              advancedDrawerController.showDrawer();
                            },
                            child: Icon(
                              Icons.menu,
                              color: Colors.black,
                            )))),
              ]),
            ));
      }),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
