import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/total_and_confirm.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_item.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/Pages/complete_order_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_element.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dynamic_grid_view.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:gap/gap.dart';

/// Questa pagina permette di creare l'ordine
/// da confermare successivamente, mostrando all'utente
/// tutti i prodotti tra cui è possibile scegliere dividendo
/// il tutto in categorie.
/// Ha inoltre la modalità gestione permettendo agli utenti con permessi
/// di gestire categorie e prodotti tra cui gli utenti potranno ordinare.

/// Fornisce un accesso diretto al carrello che permetterà successivamente di
/// passare alla pagina di completamento ordine [CompleteOrderPage]

class MakeOrderPage extends StatefulWidget {
  const MakeOrderPage({super.key});
  @override
  State<MakeOrderPage> createState() => _MakeOrderPageState();
}

class _MakeOrderPageState extends State<MakeOrderPage> {
  late CategoriesBloc categoriesBloc;
  late UserBloc userBloc;
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

  ValueNotifier<bool> loading = ValueNotifier(false);

  late GlobalKey<TotalAndConfirmState> totalAndConfirmKey;

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    categoriesBloc = CategoriesBloc(userBloc);
    cartBloc = CartBloc(userBloc, categoriesBloc);
    totalAndConfirmKey = GlobalKey();

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
    super.dispose();
  }

  void reactToCategoriesBlocState(BuildContext context, CategoriesState state)
  {
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
                  fit: StackFit.expand,
                  children: [
                    Padding(                      
                      padding: EdgeInsets.only(
                        bottom: !UIUtilities.isHorizontal(context)? 
                        TotalAndConfirm.closedPanelHeight : 0
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeaderMakeOrderPage(
                                expanded: MediaQuery.of(context).size.width > 680,
                                padding: const EdgeInsets.only(top: 25, right: 25, left: 25),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 25, right: 25, left: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [                                      
                                    const Gap(20),
                                    Text(
                                      "Il nostro menu",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                )
                              ),        
                              const Gap(10),
                              BlocConsumer<CategoriesBloc, CategoriesState>(
                                bloc: categoriesBloc,
                                listener: reactToCategoriesBlocState,
                                builder: (context, state) { 
                                  return BlocBuilder<UserBloc, UserState>(
                                    builder: (context, state) {
                                      bool hasPermission = false;
                                      
                                      if (state is FetchedUserInfoState) {
                                        hasPermission = state.userInfo.hasPermission;
                                      }
                                      double padding = 20;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: padding,
                                          right: padding,
                                          bottom: padding
                                        ),
                                        child: DynamicGridView(
                                          targetItemWidth: 185,
                                          aspectRatio: 1,
                                          spacing: 20,
                                          runSpacing: 10,
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
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ]),
                      ),
                    ),
                    TotalAndConfirm(
                      key: totalAndConfirmKey,
                      confirmText: "Carrello",
                      maxHeight: 5 * MediaQuery.of(context).size.height / 6,
                      onCompleteOrderRequest: () {
                        if(userBloc.state is LoggedInState)
                        {
                          if(cartBloc.state.cart.isNotEmpty)
                          {
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
                          }
                          else{
                            DialogShower.showAlertDialog(
                              context, 
                              "Il carrello è vuoto", 
                              "Prima di completare l'ordine, metti qualcosa nel carrello."
                            );
                          }
                        }
                        else {
                          DialogShower.showAlertDialog(
                            context, 
                            "Login", 
                            "Effettua il login prima di completare l'ordine."
                          );
                        }
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

class HeaderMakeOrderPage extends StatelessWidget
{
  static const double bannerHeight = 200;
  static const double imageSize = 120;
  static const double imageFractionOut = 1/5;

  final EdgeInsets padding;
  final bool expanded;

  const HeaderMakeOrderPage({
    super.key,
    required this.expanded,
    required this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: expanded? EdgeInsets.zero : padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double margin = (expanded? 0 : imageSize  * imageFractionOut);
          return SizedBox(
            height: bannerHeight,
            child: Stack(
              children: [
                Container(
                  height: bannerHeight - margin,
                  width: constraints.maxWidth - margin,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: expanded? null : BorderRadius.circular(defaultBorderRadius)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left:20,
                      top: 20,
                      bottom: 20,
                      right: 20 + imageSize * (1 - imageFractionOut),
                    ),
                    child: IntrinsicHeight(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 700
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "I nostri piatti",
                                      style:Theme.of(context)
                                      .textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary
                                      ),
                                    ),
                                    Text(
                                      "Direttamente a casa tua "
                                      "in pochi, semplici, passi. ",
                                      style:Theme.of(context)
                                      .textTheme.titleMedium?.copyWith(
                                        color: Colors.white
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if(expanded)
                              SizedBox(
                                height: bannerHeight,
                                width: imageSize,
                                child: Image.asset(
                                  "assets/delivery.png",
                                  alignment: Alignment.center,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if(!expanded)
                Positioned(
                  right: 0,
                  height: bannerHeight,
                  width: imageSize,
                  child: Image.asset(
                    "assets/delivery.png",
                    alignment: Alignment.bottomCenter,
                  )
                )
              ],
            ),
          );
        }
      ),
    );
  }

}