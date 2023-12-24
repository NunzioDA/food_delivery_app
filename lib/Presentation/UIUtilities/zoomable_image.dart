import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Pages/image_show.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/to_visualizer_bridge.dart';


/// Permette di effettuare l'animazione di visualizzazione di un immagine
/// con [SuperHero] 

class ZoomableImage extends StatelessWidget
{
  final ImageProvider? provider;
  final FdaCachedNetworkImage? image;
  const ZoomableImage({
    super.key,
    this.provider,
    this.image
  }) : assert((image != null) != (provider != null));

  @override
  Widget build(BuildContext context) {
    return SuperHero(
      onPageReturn: (v){}, 
      tag: "ImageToBridge", 
      generateRoute: () => PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageVisualizer(
            image: provider ?? image!.getImageProvider(),
            heroTag: "ImageBridgeToVisualizer",
          );
        },
      ), 
      child: provider != null? Image(
        image: provider!,
        fit: BoxFit.cover,
      ): image!
    );
  }
}
