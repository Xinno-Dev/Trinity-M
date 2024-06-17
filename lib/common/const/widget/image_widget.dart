import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/const/constants.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/uihelper.dart';

import '../utils/convertHelper.dart';

showImage(String url, Size size, {BoxFit? fit}) {
  if (url.isEmpty) return Container();
  if (url.contains('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      width:  size.width  > 0 ? size.width  : null,
      height: size.height > 0 ? size.height : null,
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
      errorListener: (listener) {
        LOG('--> errorListener [$url] : $listener');
      },
      errorWidget: (context, error, object) {
        return Container(
          color: GRAY_20,
          alignment: Alignment.center,
          child: Text('no image..',
            style: typo14normal, textAlign: TextAlign.center),
        );
      },
      fit: fit ?? BoxFit.cover
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
    url,
    width:  size.width  > 0 ? size.width  : null,
    height: size.height > 0 ? size.height : null,
    fit: fit);
}

class NetworkImageInfo {
  String? path;
  Image?  image;
  Size?   size;
}

Future<NetworkImageInfo> getNetworkImageInfo(
  String? imagePath, {Size? showSize, var fit = BoxFit.fill}) async {
  if (STR(imagePath).contains('http')) {
    var result = NetworkImageInfo();
    if (STR(imagePath).isEmpty) return result;
    var completer = Completer<NetworkImageInfo>();
    result.image = Image(image: CachedNetworkImageProvider(imagePath!),
        width: showSize?.width,
        height: showSize?.height,
        fit: fit); // I modified this line
    result.image!.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          result.size =
              Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(result);
        },
      ),
    );
    return completer.future;
  }
  return NetworkImageInfo();
}
