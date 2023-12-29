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
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
                tileMode: TileMode.decal
              ),
              child: ImageIcon(
                CachedNetworkImageProvider(
                  FdaServerCommunication.getImageUrl(
                    imageName
                  ),
                ),
                color: Colors.black.withAlpha(100),
                size: size,
              ),
            ),
            SizedBox(
              height: size-1,
              width: size-1,
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