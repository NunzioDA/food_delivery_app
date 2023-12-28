import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';

/// Widget che può essere visualizzato in Layout a scorrimento 
/// per aggiungere un elmento generico.

class AddElementWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String? containerTag;
  final String? iconTag;
  const AddElementWidget({
    super.key, 
    required this.onPressed,
    this.containerTag,
    this.iconTag
  });

  Widget icon(BuildContext context)
  {
    return IgnorePointer(
      child: Material(
        color: Theme.of(context).primaryColorLight,
        child: Icon(
          Icons.add,
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }


  Widget container(BuildContext context)
  {
    return Material(
      color: Theme.of(context).primaryColorLight,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: InkWell(   
        onTap: onPressed.call,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
          (containerTag!=null)?
          Hero(
            flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => container(context),
            tag: containerTag!, 
            child: container(context)
          ):
          container(context),
          Center(
            child: (iconTag!=null)?
            Hero(
              flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => icon(context),
              tag: iconTag!, 
              child: icon(context)
            ):
            icon(context),
          ),
        ],
      )
    );
  }
}