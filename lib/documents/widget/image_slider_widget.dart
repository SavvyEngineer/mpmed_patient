import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:photo_view/photo_view.dart';

class image_slider_widget extends StatelessWidget {
  const image_slider_widget(
      {Key? key,
      required this.id,
      required this.mediaData,
      this.height = 190,
      this.width = 130,
      this.autoPlay = true,
      this.changeDirection = Axis.horizontal,
      this.imageScale = BoxFit.fill,
      this.is_full_screen = false})
      : super(key: key);

  final int id;
  final double height;
  final double width;
  final List<DocumentMediaModel> mediaData;
  final Axis changeDirection;
  final BoxFit imageScale;
  final bool autoPlay;
  final bool is_full_screen;


  @override
  Widget build(BuildContext context) {
    List<String> mediaLink = [];
    mediaData.forEach((element) {
      if (element.docId == id) {
        mediaLink.add(element.docUrl);
      }
    });
    return Container(
        margin: EdgeInsets.only(left: 1, right: 10),
        height: height,
        width: width,
        child: CarouselSlider.builder(
          itemCount: mediaLink.length,
          options: CarouselOptions(
            height: height - 20,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: autoPlay,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: null,
            scrollDirection: changeDirection,
          ),
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  Container(
            child: Container(
              height: height + 10,
              width: double.infinity,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:is_full_screen
                      ? PhotoView(
                          imageProvider:
                              CachedNetworkImageProvider(mediaLink[itemIndex]))
                      :CachedNetworkImage(
                    imageUrl: mediaLink[itemIndex],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
            ),
          ),
        ));
  }
}
