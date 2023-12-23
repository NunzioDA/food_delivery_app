import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Pages/image_show.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';

/// Permette di effettuare l'animazione di transizione 
/// con [Hero] evitando la restrizione di discendenza tra widget [Hero]
/// passando per una pagina che fa da ponte [_BridgePage]
class SuperHero extends StatefulWidget
{
  final Object? tag;
  final Route<dynamic> Function() generateRoute;
  final void Function(dynamic value) onPageReturn;
  final Widget? childWithHeros;
  final Widget child;

  const SuperHero({
    super.key,
    required this.onPageReturn,
    required this.tag,
    required this.generateRoute,
    required this.child,
    this.childWithHeros,
  });

  @override
  State<SuperHero> createState() => _SuperHeroState();
}

class _SuperHeroState extends State<SuperHero> {
  bool visualizing = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey key = GlobalKey();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: (e){
        setState(() => visualizing = true);
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return _BridgePage(
                tag: widget.tag,
                route: widget.generateRoute.call(),
                childKey: key,
                hasHero:  widget.childWithHeros != null,
                child: widget.childWithHeros ?? widget.child,
              );
            },
          )
        ).then((value) async{
          widget.onPageReturn.call(value);
          // Attesa del completamento dell'animazione
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() => visualizing = false);
        });

      },
      child: Container(
        key: key,
        child: !visualizing? 
        widget.child
        : null,
      ),
    );
  }
}


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

/// Questa pagina è il ponte tra [SuperHero] e la pagina da visualizzare
/// andando a visualizzare un widget identico a quello contenuto
/// in [SuperHero] nella stessa posizione e con le stesse dimensioni usando 
/// uno [Stack] e le informazioni ricavate dalla chiave appartenente al 
/// container che circonda il figlio di [SuperHero].
/// Quando il widget è stato costruito questo procede al push della pagina specificata
/// per avviare l'animazione di transizione tramite [Hero].
/// Resta poi in attesa del pop della pagina per effettuare a sua volta
/// il pop tornando alla pagina chiamante.
class _BridgePage extends StatefulWidget
{
  final Route<dynamic> route;
  final Object? tag;
  final GlobalKey childKey;
  final bool hasHero;
  final Widget child;

  const _BridgePage({
    required this.tag,
    required this.child,
    required this.childKey,
    required this.route,
    required this.hasHero
  });

  @override
  State<_BridgePage> createState() => _BridgePageState();
}

class _BridgePageState extends State<_BridgePage> {

  
  (Size,Offset) getImageSizeAndPosition()
  {
     final RenderBox renderBox = widget.childKey.currentContext?.findRenderObject() as RenderBox;
 
    final Size size = renderBox.size; 
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return (size, offset);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => 
      await Navigator.of(context).push(
        // PageRouteBuilder(
        //   opaque: false,
        //   pageBuilder: (context, animation, secondaryAnimation) => ImageVisualizer(
        //     image: widget.imageProvider,
        //     heroTag: "ImageBridgeToVisualizer",
        //   ),
        // )
        widget.route
      ).then((value) => Navigator.of(context).pop(value))
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
          child: widget.hasHero? widget.child:
          Hero(
            tag:"ImageBridgeToVisualizer",
            child: widget.child
          )
        )
      ],
    );
  }
}