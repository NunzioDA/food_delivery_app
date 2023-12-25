import 'package:flutter/material.dart';

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
  late GlobalKey key;
  Size? childSize;


  @override
  void initState() {
    key = GlobalKey();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!visualizing)
      {
        childSize = key.currentContext?.size;
      }      
    } 
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
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
      child: IgnorePointer(
        child: SizedBox(
          key: key,
          width: visualizing? childSize?.width : null,
          height: visualizing? childSize?.height : null,
          child: !visualizing? 
          widget.child
          : null,
        ),
      ),
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