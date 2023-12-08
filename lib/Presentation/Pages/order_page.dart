import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/Utilities/add_element.dart';
import 'package:food_delivery_app/Presentation/Utilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/Utilities/category_info.dart';
import 'package:food_delivery_app/Presentation/Utilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/Utilities/loading.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:gap/gap.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late CategoriesBloc categoriesBloc;
  late UserBloc userBloc;
  late CartBloc cartBloc;

  ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    categoriesBloc = CategoriesBloc(userBloc);
    cartBloc = BlocProvider.of<CartBloc>(context);

    updateCategories();
    super.initState();
  }

  void openCategoryPage(
    ProductsCategory? category,
    bool creationMode,
    bool hasPermission,
  ) async {
    var newCategoryPair = await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: categoriesBloc,
            ),
            BlocProvider.value(
              value: cartBloc,
            ),
          ],
          child: CategoryPage(
            category: category,
            creationMode: creationMode,
            hasPermission: hasPermission,
          ),
        );
      },
    ));

    if (newCategoryPair != null) {
      categoriesBloc.add(
        CategoriesCreateEvent(
          ProductsCategory(newCategoryPair.$1, "", []),
          newCategoryPair.$2 //Immagine
        )
      );
    }
  }

  void updateCategories() {
    loading.value = true;
    categoriesBloc.add(const CategoriesFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FdaLoading(
        loadingNotifier: loading,
        dynamicText: ValueNotifier("Sto caricando i dati.."),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Da te\nIn pochi passi",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Gap(20),
                Text(
                  "Ecco i nostri prodotti",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Expanded(
                  child: BlocConsumer<CategoriesBloc, CategoriesState>(
                    bloc: categoriesBloc,
                    listener: (context, state) {
                      loading.value = false;

                      if (state is CategoriesErrorState &&
                          state.event is! CategoryDeleteEvent) {
                            print(state.error);
                        DialogShower.showAlertDialog(
                            context,
                            "Attenzione!",
                            "Si è verificato un errore nella gesione dei dati\n"
                                "Se il problema persiste contattaci!");
                      } else if (state is CategoryAlreadyExisting) {
                        DialogShower.showAlertDialog(context, "Attenzione!",
                            "La categoria che stai cercando di creare esiste già.");
                      } else if (state is CategoryCreatedSuccesfully) {
                        DialogShower.showAlertDialog(context, "Fatto!",
                                "La categoria è stata creata correttamente")
                            .then((value) => updateCategories());
                      } else if (state is CategoryDeletedSuccesfully) {
                        updateCategories();
                      }
                    },
                    builder: (context, state) {
                      return BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          bool hasPermission = false;

                          if (state is FetchedUserInfoState) {
                            hasPermission = state.userInfo.hasPermission;
                          }

                          return GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              ...categoriesBloc.state.categories
                                  .map(
                                    (e) => CategoryWidget(
                                      category: e,
                                      onPressed: () {
                                        openCategoryPage(
                                            e, false, hasPermission);
                                      },
                                    ),
                                  )
                                  .toList(),
                              if (hasPermission)
                                AddElementWidget(
                                  onPressed: () {
                                    openCategoryPage(null, true, hasPermission);
                                  },
                                )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ]),
        ),
      ),
    ));
  }
}


class CategoryWidget extends StatefulWidget {
  static const double imageSize = 80;

  final ProductsCategory category;
  final VoidCallback onPressed;
  const CategoryWidget(
      {super.key, required this.category, required this.onPressed});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
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
              fixedCount: (animation!=null)? count : null,
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
            const Gap(CategoryWidget.imageSize / 2),
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
              height: CategoryPage.imageSize,
              width: CategoryPage.imageSize,
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
