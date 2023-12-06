import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FdaLoading extends StatefulWidget
{
  final ValueNotifier<bool> loadingNotifier;
  final ValueNotifier<String> dynamicText;

  final Widget child;
  const FdaLoading({
    super.key,
    required this.loadingNotifier,
    required this.dynamicText,
    required this.child
  });

  @override
  State<FdaLoading> createState() => _FdaLoadingState();
}

class _FdaLoadingState extends State<FdaLoading> {

  late VoidCallback action = () {
    if(mounted) setState(() {});
  };

  @override
  void initState() {
    widget.loadingNotifier.addListener(action);
    widget.dynamicText.addListener(action);
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
    return Stack(
      children: [
        widget.child,
        if(widget.loadingNotifier.value)
        Container(
          constraints: const BoxConstraints.expand(),
          color: Theme.of(context).primaryColorDark.withAlpha(110),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.twoRotatingArc(
                  color: Theme.of(context).primaryColor, 
                  size: 100
                ),
                const SizedBox(height: 20),                
                Text(
                  widget.dynamicText.value,                  
                  style: const TextStyle(
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        )     
      ],
    );
  }
}