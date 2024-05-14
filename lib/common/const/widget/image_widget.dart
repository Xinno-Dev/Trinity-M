import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';

import '../utils/convertHelper.dart';

showImage(String imagePath, Size size, {BoxFit? fit}) {
  if (imagePath.isEmpty) return Container();
  if (imagePath.contains('https:')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: size.width, height: size.height,
      placeholder: (context, _) => Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: GRAY_20
        ),
        alignment: Alignment.center,
        child: showLoadingFull(min(size.height, size.width) * 0.25),
      ),
      fit: BoxFit.cover
    );
    // return FutureBuilder(future: getNetworkImageInfo(
    //   imagePath, showSize: size, fit: fit),
    //   builder: (context, snapshot) {
    //   if (snapshot.hasData) {
    //     // LOG('---> showImage size : ${imagePath} / ${snapshot.data}');
    //     var info = snapshot.data as NetworkImageInfo;
    //     return info.image ?? Container();
    //   } else {
    //     return size.width > 0 ? Container(
    //       width: size.width, height: size.height,
    //       alignment: Alignment.center,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         color: GRAY_10
    //       ),
    //       child: showLoadingFull(30)
    //     ) : showLoadingFull(30);
    //   }
    // });
  }
  return Image.asset(
    imagePath,
    width: size.width, height: size.height,
    fit: fit);
}

class NetworkImageInfo {
  String? path;
  Image?  image;
  Size?   size;
}

Future<NetworkImageInfo> getNetworkImageInfo(
  String? imagePath, {Size? showSize, var fit = BoxFit.fill}) async {
  var result = NetworkImageInfo();
  if (STR(imagePath).isEmpty) return result;
  var completer = Completer<NetworkImageInfo>();
  result.image = Image(image: CachedNetworkImageProvider(imagePath!),
      width: showSize?.width, height: showSize?.height, fit: fit); // I modified this line
  result.image!.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        result.size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(result);
      },
    ),
  );
  return completer.future;
}
