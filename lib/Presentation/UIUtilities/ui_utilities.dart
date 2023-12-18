import 'package:flutter/material.dart';


bool scrollParentOnChildOverscroll (
  OverscrollNotification notification,
  ScrollController parentScrollController
) {
  if (parentScrollController.position.maxScrollExtent > 0) {
    if (notification.metrics.pixels ==
        notification.metrics.maxScrollExtent) {
      parentScrollController.jumpTo(
        parentScrollController.offset + notification.overscroll);
    } else if (notification.metrics.pixels ==
        notification.metrics.minScrollExtent) {
      parentScrollController.jumpTo(
        parentScrollController.offset + notification.overscroll);
    }
  }
  return true;
}

Color defaultTransparentScaffoldBackgrounColor(BuildContext context)
{
  return Theme.of(context).primaryColor.withAlpha(110);
}

class UIUtilities{
  static bool isHorizontal(BuildContext context)
  {
    Size size = MediaQuery.of(context).size;
    return size.width > size.height;
  } 
}

const double defaultBorderRadius = 10;
const double defaultElevation = 5;
