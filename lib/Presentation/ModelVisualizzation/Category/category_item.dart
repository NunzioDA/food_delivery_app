import 'package:flutter/material.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_info.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:gap/gap.dart';

/// Questo widget può essere usato in layout a scorrimento
/// per la visualizzazione delle informazioni riguardanti
/// una collezione di [ProductsCategory].

class CategoryItem extends StatefulWidget {
  static const double imageSize = 90;

  final ProductsCategory category;
  final VoidCallback onPressed;
  const CategoryItem(
      {super.key, required this.category, required this.onPressed});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  int count = 0;

  Widget categoryWidgetContent(BuildContext context,
      [Animation<double>? animation, HeroFlightDirection? flightDirection]) {
    return Material(
      elevation: 10,
      color: Theme.of(context).dialogBackgroundColor,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CategoryInfo(
              category: widget.category,
              onCountChanged: (value) => count = value,
              fixedCount: (animation != null) ? count : null,
            ),
            if (animation != null)
              SizeTransition(
                sizeFactor:
                    Tween<double>(begin: 0, end: CategoryPage.listHeight)
                        .animate(animation),
                child: const Material(
                  child: SizedBox(height: 1),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed.call,
      child: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(CategoryItem.imageSize / 2),
            Expanded(
              child: Hero(
                  flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) =>
                      categoryWidgetContent(
                          flightContext, animation, flightDirection),
                  tag: "Container${widget.category.name}",
                  child: categoryWidgetContent(context)),
            )
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Hero(
            tag: "Image${widget.category.name}",
            child: SizedBox(
              height: CategoryItem.imageSize,
              width: CategoryItem.imageSize,
              child: FdaCachedNetworkImage(
                url: FdaServerCommunication.getImageUrl(
                    widget.category.imageName),
              ),
            ),
          ),
        )
      ]),
    );
  }
}