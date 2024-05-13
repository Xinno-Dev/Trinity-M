import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';

import '../utils/convertHelper.dart';

showImage(String imagePath, Size size, {BoxFit? fit}) {
  if (imagePath.isEmpty) return Container();
  if (imagePath.contains('https:')) {
    return FutureBuilder(future: getNetworkImageSize(imagePath),
      builder: (context, snapshot) {
      if (snapshot.hasData) {
        // LOG('---> showImage size : ${imagePath} / ${snapshot.data}');
        var orgSize = snapshot.data as Size;
        return CachedNetworkImage(
          imageUrl: imagePath,
          width: size.width, height: size.height,
          fit: fit ??
            (orgSize.width > orgSize.height ? BoxFit.fitHeight : BoxFit.fitWidth),
        );
      } else {
        return showLoadingFull(30);
      }
    });
  }
  return Image.asset(
    imagePath,
    width: size.width, height: size.height,
    fit: fit);
}

Future<Size> getNetworkImageSize(String? imagePath) async {
  if (STR(imagePath).isEmpty) return Size.zero;
  Completer<Size> completer = Completer();
  Image image = new Image(image: CachedNetworkImageProvider(imagePath!)); // I modified this line
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}
