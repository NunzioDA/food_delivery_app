import 'package:flutter/material.dart';
/// Permette di decidere il fit degli oggetti nella griglia.
/// [tight] indica di utilizzare [DynamicGridView.targetItemWidth]
/// come dimensione minima di ogni oggetto, creando un limite più forte
/// per le dimensioni degli oggetti.
/// [loose] crea un limite più morbido, cercando di dare agli oggetti una
/// dimensione simile a quella indicata.
enum DynamicGridFit
{
  tight, 
  loose
}

class DynamicGridView extends StatelessWidget{
  final EdgeInsets padding;
  final double targetItemWidth;
  final double spacing;
  final double runSpacing;
  final double? aspectRatio;
  final List<Widget> children;
  final DynamicGridFit fit;
 

  const DynamicGridView({
    super.key,
    this.padding = EdgeInsets.zero,
    this.spacing = 0,
    this.runSpacing = 0,
    this.aspectRatio,
    this.fit = DynamicGridFit.tight,
    required this.targetItemWidth,
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
                          
          double availableSpace = (constraints.maxWidth);
                        
          int maxItemPerRow;

          if(fit == DynamicGridFit.loose)
          {
            maxItemPerRow = (availableSpace / targetItemWidth).round();
          }
          else{
            maxItemPerRow = (availableSpace ~/ targetItemWidth);
          }
                                    
          if(maxItemPerRow ==0)
          {
            maxItemPerRow = 1;
          }

          availableSpace -= spacing * (maxItemPerRow -1);
          double perWidgetSpace = availableSpace / maxItemPerRow;
          double itemWidth = perWidgetSpace;
        

          return Wrap(
            direction: Axis.horizontal,
            runSpacing: runSpacing,
            spacing: spacing,
            children: children.map(
              (e) => SizedBox(
                height: aspectRatio != null? (itemWidth * aspectRatio!) : null,
                width: itemWidth,
                child: e,
              )
            ).toList(),
          );
        }
        ),
    );
  }
  
}