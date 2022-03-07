// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_patient/doctors/provider/doctor_provider.dart';
import 'package:mpmed_patient/doctors/screen/doctors_list_screen.dart';
import 'package:mpmed_patient/documents/Review/providers/review_provider.dart';
import 'package:mpmed_patient/documents/pdf_generator/pdf_generator.dart';
import 'package:mpmed_patient/documents/pdf_generator/pdf_screen.dart';
import 'package:mpmed_patient/documents/screens/document_image_picker.dart';
import 'package:mpmed_patient/documents/screens/document_import_form.dart';
import 'package:mpmed_patient/documents/screens/document_item_screen.dart';
import 'package:mpmed_patient/documents/screens/documents_cats_screen.dart';
import 'package:mpmed_patient/documents/screens/documents_screen.dart';
import 'package:mpmed_patient/documents/screens/full_screen_image_page.dart';
import 'package:mpmed_patient/documents/screens/send_multiple_docs.dart';
import 'package:mpmed_patient/notification/provider/notif_provider.dart';
import 'package:mpmed_patient/one_question/provider/one_questions_provider.dart';
import 'package:mpmed_patient/one_question/screen/one_question_form.dart';
import 'package:mpmed_patient/one_question/screen/one_question_h_screen.dart';
import 'package:mpmed_patient/one_question/screen/one_question_item.dart';
import 'package:mpmed_patient/screens/home_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'authOtp/pages/splash_page.dart';
import 'authOtp/stores/login_store.dart';
import 'documents/provider/documents_provider.dart';
import 'notification/fcm_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
    .then((_) {
      runApp(new MyApp());
    });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalStorage storage = new LocalStorage('userData');

  _getNtcodeFromLS() async {
    await storage.ready;
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
    setupFcm();
  }

  @override
  void initState() {
    _getNtcodeFromLS();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: NotifProvider()),
        ChangeNotifierProvider.value(value: DocumentsProvider()),
        ChangeNotifierProvider.value(value: DoctorProvider()),
        ChangeNotifierProvider.value(value: ReviewProvider()),
        ChangeNotifierProvider.value(value: OneQuestionsProvider()),
        Provider<LoginStore>(create: (_) => LoginStore()),
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("fa", "IR"), // OR Locale('ar', 'AE') OR Other RTL locales
        ],
        locale: Locale("fa", "IR"),
        theme: ThemeData(
          fontFamily: 'kalameh',
        ),
        home: SplashPage(),
        routes: {
          SplashPage.routeName: (ctx) => SplashPage(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          DocumentsCatsScreen.routeName: (ctx) => DocumentsCatsScreen(),
          DocumentsScreen.routeName: (ctx) => DocumentsScreen(),
          DocumentImportForm.routeName: (ctx) => DocumentImportForm(),
          DocumentImagePicker.routeName: (ctx) => DocumentImagePicker(),
          DocumentItemScreen.routeName: (ctx) => DocumentItemScreen(),
          DoctorsListScreen.routeName: (ctx) => DoctorsListScreen(),
          FullScreenImageViewer.routeName:(ctx)=> FullScreenImageViewer(),
          PDFScreen.routeName: (ctx) => PDFScreen(),
          SendMultipleDocuments.routeName: (ctx) => SendMultipleDocuments(),
          OneQuestionHome.routeName: (ctx) => OneQuestionHome(),
          QuestionItemScreen.routeName: (ctx) => QuestionItemScreen(),
          OneQuestionImportForm.routeName: (ctx) => OneQuestionImportForm()
        },
      ),
    );
  }
}
