import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';

class DialogPageTemplate extends StatelessWidget
{
  final Widget child;
  const DialogPageTemplate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      backgroundColor: defaultTransparentScaffoldBackgrounColor(context),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(),
            ),
            child,
            
          ]
        ),
      )
    );
  }

}