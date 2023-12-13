import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_item.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/Pages/complete_order_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_element.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/total_and_confirm.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
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
  late StreamSubscription cartSubscription, userSubscription;

  ValueNotifier<bool> loading = ValueNotifier(false);

  GlobalKey<TotalAndConfirmState> totalAndConfirmKey = GlobalKey();

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    categoriesBloc = CategoriesBloc(userBloc);
    cartBloc = CartBloc(userBloc, categoriesBloc);

    updateCategories();  
    

    
    cartSubscription = cartBloc.stream.listen((event) {
      if(event is CartError && event.event is FetchCart)
      {
        DialogShower.showAlertDialog(
          context, 
          "Oops..", 
          "Non sono riuscito a recuperare il tuo carrello.\n"
          "Se il problema persiste contattaci!"
        );
        print(event.error);
      }
    });
    
    super.initState();
  }
  @override
  void dispose() {
    cartSubscription.cancel();
    userSubscription.cancel();
    super.dispose();
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
      categoriesBloc.add(CategoriesCreateEvent(
          ProductsCategory(newCategoryPair.$1, "", []),
          newCategoryPair.$2 //Immagine
          ));
    }
  }

  void updateCategories() {
    loading.value = true;
    categoriesBloc.add(const CategoriesFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: totalAndConfirmKey.currentState?.isOpened() ?? false,
      onPopInvoked: (didPop) async {
        if (!didPop && (totalAndConfirmKey.currentState?.isOpened() ?? false)) {
          totalAndConfirmKey.currentState?.close();
        } 
      },
      child: Scaffold(
          body: BlocProvider<CartBloc>(
            create: (context) => cartBloc,
            child: SafeArea(
              child: FdaLoading(
                loadingNotifier: loading,
                dynamicText: ValueNotifier("Sto caricando i dati.."),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: TotalAndConfirm.closedPanelHeight -
                              defaultBorderRadius),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 25, right: 25, left: 25),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Da te\nIn pochi passi",
                                      style:
                                          Theme.of(context).textTheme.headlineLarge,
                                    ),
                                    const Gap(20),
                                    Text(
                                      "Ecco i nostri prodotti",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ]),
                            ),
                            const Gap(10),
                            Expanded(
                              child: BlocConsumer<CategoriesBloc, CategoriesState>(
                                bloc: categoriesBloc,
                                listener: (context, state) {
                                  loading.value = false;
                
                                  if (state is CategoriesErrorState &&
                                      state.event is! CategoryDeleteEvent) {
                                    DialogShower.showAlertDialog(
                                        context,
                                        "Attenzione!",
                                        "Si è verificato un errore nella gesione dei dati\n"
                                            "Se il problema persiste contattaci!");
                                  } else if (state is CategoryAlreadyExisting) {
                                    DialogShower.showAlertDialog(
                                        context,
                                        "Attenzione!",
                                        "La categoria che stai cercando di creare esiste già.");
                                  } else if (state is CategoryCreatedSuccesfully) {
                                    DialogShower.showAlertDialog(context, "Fatto!",
                                            "La categoria è stata creata correttamente")
                                        .then((value) => updateCategories());
                                  } else if (state is CategoryDeletedSuccesfully) {
                                    updateCategories();
                                  }
                                  else if(state is CategoriesFetched)
                                  {
                                    cartBloc.add(const FetchCart());
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
                                        padding: const EdgeInsets.all(25),
                                        children: [
                                          ...categoriesBloc.state.categories
                                              .map(
                                                (e) => CategoryItem(
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
                                                openCategoryPage(
                                                    null, true, hasPermission);
                                              },
                                            )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ]),
                    ),
                    TotalAndConfirm(
                      key: totalAndConfirmKey,
                      confirmText: "Carrello",
                      maxHeight: 5 * MediaQuery.of(context).size.height / 6,
                      onCompleteOrderRequest: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (newC, animation, secondaryAnimation) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: cartBloc,
                              ),
                              BlocProvider.value(
                                value: BlocProvider.of<OrderBloc>(context),
                              )
                            ],
                            child: const CompleteOrderPage(),
                          ),
                          )
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
