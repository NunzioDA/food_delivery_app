import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageVisualizer extends StatelessWidget
{
  final ImageProvider image;
  final String heroTag;
  const ImageVisualizer({super.key, required this.image, required this.heroTag});

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PhotoView(
              imageProvider: image, 
              gestureDetectorBehavior: HitTestBehavior.translucent, 
              heroAttributes: PhotoViewHeroAttributes(
                tag: heroTag
              ),
              backgroundDecoration: BoxDecoration(
                color: Colors.black.withAlpha(230)                      
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: 1.5,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  iconSize: 30,
                  onPressed: ()=>Navigator.of(context).pop(), 
                  icon: const Icon(Icons.arrow_back, color: Colors.white,)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}