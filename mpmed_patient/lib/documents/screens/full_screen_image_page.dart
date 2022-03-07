import 'package:flutter/material.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:mpmed_patient/documents/widget/image_slider_widget.dart';

class FullScreenImageViewer extends StatefulWidget {
  static const String routeName = '/full_screen_viewer';

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int documentId = 0;

  List<DocumentMediaModel> documentData = [];
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final Map<String, dynamic> map =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      documentId = map['documentId'];
      documentData = map['documentMediaList'];
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: image_slider_widget(
      id: documentId,
      mediaData: documentData,
      changeDirection: Axis.horizontal,
      imageScale: BoxFit.fill,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 30,
      autoPlay: false,
      is_full_screen: true,
    ),
        ));
  }
}
