import 'package:flutter/material.dart';
import 'dart:async';

import 'package:multi_image_picker2/multi_image_picker2.dart';

class DocumentImagePicker extends StatefulWidget {
  static const String routeName = "/image_picker";
  @override
  _DocumentImagePickerState createState() => _DocumentImagePickerState();
}

class _DocumentImagePickerState extends State<DocumentImagePicker> {
  List<Asset> images = <Asset>[];

  String _error = 'No Error Detected';

  Widget buildGridView() {
    // images.forEach((element) {
    //   print(element.identifier.toString());
    // });

    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(asset: asset, width: 300, height: 300);
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 9,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(
            takePhotoIcon: "chat",
            doneButtonTitle: "Fatto",
          ),
          materialOptions: MaterialOptions(
              actionBarColor: "#abcdef",
              actionBarTitle: "تصاویر انتخاب شده",
              selectionLimitReachedText: 'شما فقط میتوانید ۹ عکس را انتخاب کنید',
              allViewTitle: "All Photos",
              useDetailsView: false,
              selectCircleStrokeColor: "#000000"));
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصاویر انتخابی شما'),
      ),
      body: Column(
        children: [
          // Center(
          //   child: Text('Error: &_error'),
          // ),
          Expanded(child: buildGridView()),
          ElevatedButton(onPressed: loadAssets, child: Text("تصاویر را انتخاب کنید")),
          ElevatedButton(onPressed: (){
            Navigator.pop(context,images);
          }, child:Text('انتخاب انجام شد'))
        ],
      ),
    );
  }
}
