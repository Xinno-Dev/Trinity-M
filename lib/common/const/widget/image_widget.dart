import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/convertHelper.dart';

showImage(String imagePath, Size size, {BoxFit? fit}) {
  if (imagePath.contains('https:')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: size.width, height: size.height,
      fit: fit,
    );
  }
  return Image.asset(
    imagePath,
    width: size.width, height: size.height,
    fit: fit);
}
