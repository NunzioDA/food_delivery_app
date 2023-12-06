import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:gap/gap.dart';

class CategoryPage extends StatelessWidget{
  static const double imageSize = 90;
  static const double listHeight = 500;

  final ProductsCategory category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {    

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withAlpha(110),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: SizedBox(
              height: imageSize + listHeight + 70,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,                
                    children: [
                      const Gap(imageSize/2),
                      Hero(
                        tag: "Container${category.name}",
                        child: Material(
                          elevation: 10,
                          color: Theme.of(context).dialogBackgroundColor,
                          borderRadius: BorderRadius.circular(defaultBorderRadius),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text("${category.products.length} prodotti"),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: listHeight,
                                    minHeight: 1
                                  ),
                                  child: ListView.builder(
                                    itemCount: category.products.length,
                                    itemBuilder: (context, index) {
                                      return Text(category.products[index].name);
                                    },
                                  )
                                )                            
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Hero(
                      tag: "Image${category.name}",
                      child: const Icon(
                        Icons.piano,
                        size: imageSize,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}