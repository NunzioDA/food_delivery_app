import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FdaLoading extends StatelessWidget
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        _FdaLoadingVisualizer(
          loadingNotifier: loadingNotifier,
          dynamicText: dynamicText,
        )
      ],
    );
  }
}

class _FdaLoadingVisualizer extends StatefulWidget {

  final ValueNotifier<bool> loadingNotifier;
  final ValueNotifier<String> dynamicText;

  const _FdaLoadingVisualizer({
    required this.loadingNotifier,
    required this.dynamicText,
  });

  @override
  State<_FdaLoadingVisualizer> createState() => _FdaLoadingVisualizerState();
}

class _FdaLoadingVisualizerState extends State<_FdaLoadingVisualizer> {

  void action() {
    if(mounted) setState(() {});
  }

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
    return widget.loadingNotifier.value? 
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
            const Gap(30),                
            Text(
              widget.dynamicText.value,                  
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white
              )
            ),
          ],
        ),
      ),
    ):
    Container();
  }
}