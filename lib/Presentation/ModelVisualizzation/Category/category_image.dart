import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';

class CategoryImage extends StatelessWidget{
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
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 1.5,
                sigmaY: 1.5,
                tileMode: TileMode.decal
              ),
              child: Image(
                image: CachedNetworkImageProvider(
                  FdaServerCommunication.getImageUrl(
                    imageName
                  ),
                ),
                color: Colors.black.withAlpha(90),
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: size-2.5,
              width: size-2.5,
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