import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:gap/gap.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CategoriesBloc categoriesBloc;

  @override
  void initState() {
    categoriesBloc = CategoriesBloc();
    categoriesBloc.add(const CategoriesFetchEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Da te\nIn pochi passi",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(20),
              Text(
                "Ecco i nostri prodotti",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  bloc: categoriesBloc,
                  builder: (context, state) {
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        ...categoriesBloc.state.categories
                            .map(
                              (e) => CategoryWidget(
                                category: e,
                                onPressed: (){
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, animation, secondaryAnimation) {
                                        return CategoryPage(
                                          category: e,                                            
                                        );
                                      },
                                    ) 
                                  );
                                },
                              ),
                            )
                            .toList(),
                        AddCategoryWidget(
                          onPressed: () {},
                        )
                      ],
                    );
                  },
                ),
              )
            ]),
      ),
    ));
  }
}

class AddCategoryWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const AddCategoryWidget({super.key, required this.onPressed});

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

class CategoryWidget extends StatefulWidget {
  static const double imageSize = 80;

  final ProductsCategory category;
  final VoidCallback onPressed;
  const CategoryWidget({
    super.key, 
    required this.category,
    required this.onPressed
  });  

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {

  Widget categoryWidgetContent(
    BuildContext context, 
    [
      Animation<double>? animation,
      HeroFlightDirection? flightDirection
    ]
  ){

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
            Text(
              widget.category.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text("${widget.category.products.length} prodotti"),
            if(animation!=null)
            SizeTransition(
              sizeFactor: Tween<double>(
                begin:0, 
                end:CategoryPage.listHeight - 3
              ).animate(animation),
              // axisAlignment: (2*flightDirection!.index - 1).toDouble(),
              child: Material(
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
            const Gap(CategoryWidget.imageSize / 2),
            Expanded(
              child: Hero(
                flightShuttleBuilder: (
                  flightContext, 
                  animation, 
                  flightDirection, 
                  fromHeroContext,
                  toHeroContext
                ) => categoryWidgetContent(flightContext, animation, flightDirection),                
                tag: "Container${widget.category.name}",                  
                child: categoryWidgetContent(context)
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Hero(
            tag: "Image${widget.category.name}",
            child: const Icon(
              Icons.piano,
              size: CategoryWidget.imageSize,
            ),
          ),
        )
      ]),
    );
  }
}
