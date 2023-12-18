import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Pages/image_show.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';

/// Permette di effettuare l'animazione di visualizzazione di un immagine
/// con [Hero] evitando la restrizione di discendenza tra widget [Hero]
/// utilizzando una pagina che fa da ponte [_ToVisualizerBridge]

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
    final GlobalKey key = GlobalKey();
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return _ToVisualizerBridge(
                imageProvider: provider ?? image!.getImageProvider(), 
                imgKey: key
              );
            },
          )
        );
      },
      child: Container(
        key: key,
        child: provider != null? Image(
          image: provider!,
          fit: BoxFit.cover,
        ):image,
      ),
    );
  }
}

/// Questa pagina è il ponte tra [ZoomableImage] e [ImageVisualizer]
/// andando a visualizzare un'immagine identica a quella contenuta 
/// in [ZoomableImage] nella stessa posizione e con le stesse dimensioni usando 
/// uno [Stack] e le informazioni ricavate dalla chiave appartenente al 
/// container nel widget [ZoomableImage].
/// Quando il widget è stato costruito questo procede al push di [ImageVisualizer]
/// per avviare l'animazione di transizione tramite [Hero].
/// Resta poi in attesa del pop dell'[ImageVisualizer] per effettuare a sua volta
/// il pop tornando alla pagina chiamante.
class _ToVisualizerBridge extends StatefulWidget
{
  final ImageProvider imageProvider;
  final GlobalKey imgKey;
  const _ToVisualizerBridge({
    required this.imageProvider,
    required this.imgKey
  });

  @override
  State<_ToVisualizerBridge> createState() => _ToVisualizerBridgeState();
}

class _ToVisualizerBridgeState extends State<_ToVisualizerBridge> {

  
  (Size,Offset) getImageSizeAndPosition()
  {
     final RenderBox renderBox = widget.imgKey.currentContext?.findRenderObject() as RenderBox;
 
    final Size size = renderBox.size; 
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return (size, offset);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => 
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => ImageVisualizer(
            image: widget.imageProvider,
            heroTag: "ImageBridgeToVisualizer",
          ),
        )
      ).then((value) => Navigator.of(context).pop())
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Size size;
    Offset position;

    (size, position) = getImageSizeAndPosition();

    return Stack(
      children: [
        Positioned(
          width: size.width,
          height: size.height,
          left: position.dx,
          top: position.dy,          
          child: Hero(
            tag:"ImageBridgeToVisualizer",
            child: Image(
              image: widget.imageProvider,
              fit: BoxFit.cover,
            )
          )
        )
      ],
    );
  }
}