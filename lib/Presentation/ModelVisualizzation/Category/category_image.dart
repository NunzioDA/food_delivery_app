import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';

class CategoryImage extends StatelessWidget{

  static const double imgDelta = 2;
  static const double blurSigma = 2.5;

  final String imageName;
  final double size;
  final Object tag;

  const CategoryImage({
    super.key,
    required this.imageName,
    required this.size,
    required this.tag
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:imgDelta),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                  tileMode: TileMode.decal
                ),
                child: Image(
                  image: CachedNetworkImageProvider(
                    FdaServerCommunication.getImageUrl(
                      imageName
                    ),
                  ),
                  color: Colors.black.withAlpha(150),
                  width: size-imgDelta,
                  height: size-imgDelta,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: size-imgDelta,
              width: size-imgDelta,
              child: FdaCachedNetworkImage(
                url: FdaServerCommunication.getImageUrl(
                  imageName
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}