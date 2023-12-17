import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Permete di ricoprire il widget figlio con un overlay di caricamento
/// [_FdaLoadingVisualizer] disabilitando temporaneamente l'input.
/// La visualizzazione dell'overlay viene guitata dal [ValueNotifier]
/// [loadingNotifier] booleano, che quando settato a vero renderà l'overlay 
/// visibile. Mentre tramite [dynamicText] si può eventualmente cambiare il testo
/// di caricamento per visualizzare progressi e cambiamenti.
class FdaLoading extends StatelessWidget
{
  final ValueNotifier<bool> loadingNotifier;
  final ValueNotifier<String> dynamicText;
  final Widget child;
  final GlobalKey childKey = GlobalKey();
  final BorderRadius? borderRadius;

  FdaLoading({
    super.key,
    required this.loadingNotifier,
    required this.dynamicText,
    this.borderRadius,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: childKey,
          child: child
        ),
        _FdaLoadingVisualizer(
          loadingNotifier: loadingNotifier,
          dynamicText: dynamicText,
          childKey: childKey,
          borderRadius: borderRadius,
        )
      ],
    );
  }
}

/// L'overlay si adatterà al widget figlio di [FdaLoading]
/// evitando che lo [Stack] prenda tutto lo spazio a sua disposizione
/// mantenendosi esclusivamente nei confini del widget figlio.
/// 
/// Per farlo aspetterà la costruzione per ricavare dal widget figlio
/// le informazioni riguardanti le sue dimensioni.

class _FdaLoadingVisualizer extends StatefulWidget {

  final ValueNotifier<bool> loadingNotifier;
  final ValueNotifier<String> dynamicText;
  final BorderRadius? borderRadius;
  final GlobalKey childKey;

  const _FdaLoadingVisualizer({
    required this.loadingNotifier,
    required this.dynamicText,
    required this.childKey,
    this.borderRadius
  });

  @override
  State<_FdaLoadingVisualizer> createState() => _FdaLoadingVisualizerState();
}

class _FdaLoadingVisualizerState extends State<_FdaLoadingVisualizer> {

  final double defaultSize = 100;
  final double spacing = 30;
  final double minPadding = 20;  
  late Size mySize;

  Size? getChildSize()
  {
    return widget.childKey.currentContext?.size;
  }

  double getMinSize(Size size)
  {
    return min(size.width, size.height);
  }

  void action() {
    if(mounted) 
    {
      if(widget.loadingNotifier.value)
      {          
        mySize = getChildSize()!;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    mySize = Size.zero;

    widget.loadingNotifier.addListener(action);
    widget.dynamicText.addListener(action);

    // Ricava le dimensioni del widget figlio
    // dopo la costruzione degl widget
    // per adattare l'overlay di caricamento a quest'ultimo
    WidgetsBinding.instance.addPostFrameCallback((_) => 
      setState(() {
        mySize = getChildSize()!;
      })
    );
    super.initState();
  }

  @override
  void dispose() {
    widget.dynamicText.removeListener(action);
    widget.loadingNotifier.removeListener(action);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Positioned(
      width: mySize.width,
      height: mySize.height,
      child: widget.loadingNotifier.value && mySize != Size.zero? 
      Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: Theme.of(context).primaryColorDark.withAlpha(110),
        ),
        constraints: const BoxConstraints.expand(),
        child: Align(
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double minSide = getMinSize(constraints.biggest);
              double maxLoadingSize = minSide 
              - (minPadding + (widget.dynamicText.value.isNotEmpty ? spacing : 0));
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.twoRotatingArc(
                    color: Theme.of(context).primaryColor, 
                    size: defaultSize < maxLoadingSize? 
                      defaultSize : 
                      maxLoadingSize
                  ),
                  if(widget.dynamicText.value.isNotEmpty)
                  Gap(spacing),
                  if(widget.dynamicText.value.isNotEmpty)         
                  Text(
                    widget.dynamicText.value,                  
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white
                    )
                  ),
                ],
              );
            }
          ),
        ),
      ):
      Container(),
    );
  }
}