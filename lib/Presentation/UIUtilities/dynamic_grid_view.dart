import 'package:flutter/material.dart';

class DynamicGridView extends StatelessWidget{
  final EdgeInsets padding;
  final double minItemSize;
  final double spacing;
  final double runSpacing;
  final double? aspectRatio;
  final List<Widget> children;

  const DynamicGridView({
    super.key,
    this.padding = EdgeInsets.zero,
    this.spacing = 0,
    this.runSpacing = 0,
    this.aspectRatio,
    required this.minItemSize,
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
                        
          double availableSpace = (constraints.maxWidth);
                        
          int maxItemPerRow = (availableSpace ~/ minItemSize);
                                    
          if(maxItemPerRow ==0)
          {
            maxItemPerRow = 1;
          }
      
          double perWidgetSpace = availableSpace / maxItemPerRow;
          double itemWidth = perWidgetSpace;
      
          if(maxItemPerRow != 1)
          {
            itemWidth -= spacing/2;
          }
         
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