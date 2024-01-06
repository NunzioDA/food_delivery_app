import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/total_and_confirm.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_item.dart';
import 'package:food_delivery_app/Presentation/Pages/category_page.dart';
import 'package:food_delivery_app/Presentation/Pages/complete_order_page.dart';
import 'package:food_delivery_app/Presentation/Pages/login_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_element.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dynamic_grid_view.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:food_delivery_app/cubit/connectivity_cubit.dart';
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
  late ConnectivityCubit connectivityCubit;
  late StreamSubscription connectivitySubscription;
  late CategoriesBloc categoriesBloc;
  late UserBloc userBloc;
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

  ValueNotifier<bool> loading = ValueNotifier(false);
  ValueNotifier<String> loadingText = ValueNotifier("");
  bool isLoadingCartRelated = false;

  late GlobalKey<TotalAndConfirmState> totalAndConfirmKey;

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    totalAndConfirmKey = GlobalKey();

    connectivityCubit = BlocProvider.of<ConnectivityCubit>(context);
    connectivitySubscription = connectivityCubit.stream.listen(
      (event) {
        if(event is Connected && event.restored)
        {
          updateCategories();
        }
      },
    );
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
          "Controlla la tua connessione e riprova."
        );
      }
      else if(isLoadingCartRelated)
      {
        isLoadingCartRelated = false;
        loading.value = false;
      }
    });
    
    super.initState();
  }
  @override
  void dispose() {
    connectivitySubscription.cancel();
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
              "Controlla la tua connessione e riprova.");
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
      loading.value = true;
      loadingText.value = "Recupero il carrello...";
      isLoadingCartRelated = true;
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
          child: FadeTransition(
            opacity: (creationMode)? animation : Tween<double>(begin: 1,end: 1).animate(animation),
            child: CategoryPage(
              category: category,
              creationMode: creationMode,
              hasPermission: hasPermission,
            ),
          ),
        );
      },
    ));

    if (newCategoryPair != null) {
      loading.value = true;
      loadingText.value = "Creo la categoria...";
      categoriesBloc.add(CategoriesCreateEvent(
        ProductsCategory(newCategoryPair.$1, "", []),
        newCategoryPair.$2 //Immagine
        )
      );
    }
  }

  void updateCategories() {
    loading.value = true;
    loadingText.value = "Recupero il menù...";
    categoriesBloc.add(const CategoriesFetchEvent());
  }

  void redirectToLogin()
  {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LoginSignupPage();
      },
    ));
  }

  void openCheckoutPage()
  {
    Navigator.of(context).push(
      PageRouteBuilder(     
        transitionDuration: const Duration(milliseconds: 250),                         
        reverseTransitionDuration: const Duration(milliseconds: 250),                         
        pageBuilder: (newC, animation, secondaryAnimation) =>
          MultiBlocProvider(
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0,1),
            end: Offset.zero
          ).animate(animation),
          child: child
        ),
        
      )
    ).then((value) {
      if(value != null)
      {
        loading.value = true;
        loadingText.value = "Un attimo...";
        isLoadingCartRelated = true;
      }
    },);
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
            child: FdaLoading(
              loadingNotifier: loading,
              dynamicText: loadingText,
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
                            const Gap(15),
                            Padding(
                              padding: const EdgeInsets.only(right: 25, left: 25),
                              child: Text(
                                "Il nostro menu",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),        
                            const Gap(15),
                            BlocConsumer<CategoriesBloc, CategoriesState>(
                              bloc: categoriesBloc,
                              listener: reactToCategoriesBlocState,
                              builder: (context, state) { 
                                return BlocConsumer<UserBloc, UserState>(
                                  listenWhen: (previous, current) => 
                                  previous is NotLoggedState &&
                                  current is LoggedInState || 
                                  previous is LoggedInState &&
                                  current is NotLoggedState,
                                  listener: (context,state){
                                    Cart? previousCart;

                                    if(state is LoggedInState && 
                                    state is! VerifiedLoggedInState &&
                                    state is! FetchedUserInfoState &&
                                    state is! UserErrorLoggedInState
                                    )      
                                    {
                                      previousCart = cartBloc.state.cart;        
                                    }

                                    if(state is LoggedInState){

                                    }
                                    
                                    cartBloc.add(FetchCart(previousCart));
                                  },
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
                                        targetItemWidth: 170,
                                        aspectRatio: 1.10,
                                        spacing: 20,
                                        runSpacing: 10,
                                        children: [
                                          ...categoriesBloc.state.categories
                                              .map(
                                                (e) => CategoryItem(
                                                  category: e,
                                                  onPressed: () {
                                                    if(connectivityCubit.state is Connected)
                                                    {
                                                      openCategoryPage(
                                                        e, false, hasPermission);
                                                    }
                                                    else{
                                                      DialogShower.showAlertDialog(
                                                        context, 
                                                        "Non sei connesso", 
                                                        "Sembra che tu non sia connesso. Controlla la tua connessione e riprova."
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                          if (hasPermission)
                                            AddElementWidget(
                                              containerTag: "Containernull",
                                              iconTag: "Imagenull",
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
                      if(connectivityCubit.state is Connected)
                      {
                        if(userBloc.state is LoggedInState)
                        {
                          if(cartBloc.state.cart.isNotEmpty)
                          {
                            openCheckoutPage();
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
                          redirectToLogin();
                        }
                      }
                      else {
                        DialogShower.showAlertDialog(
                          context, 
                          "Non sei connesso", 
                          "Sembra che ci siano dei problemi con la tua connessione,"
                          " controlla e riprova."
                        );
                      }                      
                    },
                  )
                ],
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        "I nostri piatti",
                                        style:Theme.of(context)
                                        .textTheme.headlineMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: AutoSizeText(
                                        "Direttamente a casa tua "
                                        "in pochi, semplici, passi. ",
                                        style:Theme.of(context)
                                        .textTheme.titleMedium?.copyWith(
                                          color: Colors.white
                                        ),
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