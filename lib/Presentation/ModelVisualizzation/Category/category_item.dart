import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_image.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_info.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
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
      elevation: defaultElevation,
      color: Theme.of(context).dialogBackgroundColor,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.only(top: CategoryPage.imageSize / 2,left:20.0, right: 20, bottom: 20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: CategoryInfo(
                category: widget.category,
                onCountChanged: (value) => count = value,
                fixedCount: (animation != null) ? count : null,
              ),
            ),
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
                      categoryWidgetContent(flightContext, animation, flightDirection),
                  tag: "Container${widget.category.name}",
                  child: categoryWidgetContent(context)),
            )
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: CategoryImage(
            tag: "Image${widget.category.name}",
            size: CategoryItem.imageSize,
            imageName: widget.category.imageName,
          ),
        )
      ]),
    );
  }
}