import 'package:flutter/material.dart';
import 'package:mpmed_patient/doctors/screen/doctors_list_screen.dart';
import 'package:mpmed_patient/documents/screens/documents_cats_screen.dart';
import 'package:mpmed_patient/documents/screens/send_multiple_docs.dart';
import 'package:mpmed_patient/one_question/screen/one_question_h_screen.dart';
import 'package:mpmed_patient/screens/home_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(30),
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
              height: 150,
              child: Image.asset(
                'assets/img/drawer_logo.png',
                fit: BoxFit.fill,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("خانه"),
              onTap: () {
                Navigator.of(context).pushNamed(HomeScreen.routeName);
              },
            ),
            // Divider(),
            // ListTile(
            //   leading: Icon(Icons.person_sharp),
            //   title: Text("ویرایش حساب کاربری"),
            //   onTap: () {
            //  //   Navigator.of(context).pushNamed(DoctorProfileScreen.routeName);
            //   },
            // ),
            Divider(),
            ListTile(
              leading: Icon(Icons.document_scanner),
              title: Text('مدارک پزشکی شما'),
              onTap: () {
                Navigator.of(context).pushNamed(DocumentsCatsScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('ارسال مدارک'),
              onTap: () {
                Navigator.of(context).pushNamed(SendMultipleDocuments.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('سوالات شما'),
              onTap: () {
                Navigator.of(context).pushNamed(OneQuestionHome.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('اسامی پزشکان'),
              onTap: () {
                Navigator.of(context).pushNamed(DoctorsListScreen.routeName);
              },
            )
          ],
        ),
      ),
    );
  }
}
