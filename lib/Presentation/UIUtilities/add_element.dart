import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';

class AddElementWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const AddElementWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Material(
        color: Theme.of(context).primaryColorLight,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        child: InkWell(
          onTap: onPressed.call,
          child: Center(
            child: Icon(
              Icons.add,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}