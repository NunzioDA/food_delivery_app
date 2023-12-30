import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Questa pagina permete di visualizzare in primo piano
/// un'immagine, potendola zoommare liberamente.
/// Si avvale, inoltre, di [Hero] per effettuare un'eventuale
/// animaizone da un'immagine nella pagina chiamante.

class ImageVisualizer extends StatelessWidget
{
  final ImageProvider image;
  final String heroTag;
  const ImageVisualizer({super.key, required this.image, required this.heroTag});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.black.withAlpha(230),
            ),
          ),
          Center(
            child: PhotoView(        
              tightMode: true,              
              imageProvider: image, 
              gestureDetectorBehavior: HitTestBehavior.translucent, 
              heroAttributes: PhotoViewHeroAttributes(
                tag: heroTag
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent                  
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: 1.5,
            ),
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
    );
  }

}