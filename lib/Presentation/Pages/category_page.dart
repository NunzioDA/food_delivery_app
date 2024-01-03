import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_image.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_info.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/Presentation/Pages/Templates/dialog_page_template.dart';
import 'package:food_delivery_app/Presentation/Pages/product_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_element.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/image_chooser.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/super_hero.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

/// Questa pagina permette all'utente di visualizzare tutti i [Product]
/// contenuti in una [ProductsCategory] tramite [ProductItem].
/// In questo modo l'utente potrà selezionare i prodotti inserendoli nel carrello.
/// Ha inoltre una modalità di gestione in cui utenti con permessi potranno
/// gestire la categoria eliminandola, o creando/eliminando prodotti.

class CategoryPage extends StatefulWidget {
  static const double imageSize = 120;
  static const double deleteIconSize = 25;

  final bool creationMode;
  final bool hasPermission;
  final ProductsCategory? category;

  const CategoryPage(
      {super.key,
      this.category,
      required this.hasPermission,
      this.creationMode = false})
      : assert((category != null) != creationMode);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? newCategoryName;
  XFile? newCategoryImage;
  GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();

  late CategoriesBloc _categoriesBloc;
  late StreamSubscription categoriesSubscription;

  ProductsCategory? myCategory;

  ValueNotifier<bool> loading = ValueNotifier(false);
  ValueNotifier<String> loadingText = ValueNotifier("");

  late ScrollController _parentScrollController;

  @override
  void initState() {
    _parentScrollController = ScrollController();
    myCategory = widget.category;

    _categoriesBloc = BlocProvider.of<CategoriesBloc>(context);
    categoriesSubscription =
        _categoriesBloc.stream.listen(manageCategoryBlocEvent);
    super.initState();
  }

  @override
  void dispose() {
    categoriesSubscription.cancel();
    super.dispose();
  }

  bool validateCategoryName() {
    return newCategoryName != null && newCategoryName!.isNotEmpty;
  }

  bool validateNewCategory() {
    bool? result = nameFormKey.currentState?.validate();
    return newCategoryImage != null && result != null && result;
  }

  void updateCategory() {
    loading.value = true;
    loadingText.value = "Recupero il menù...";
    _categoriesBloc.add(const CategoriesFetchEvent());
  }

  void manageCategoryBlocEvent(event) {
    loading.value = false;
    if (event is CategoryDeletedSuccesfully) {
      categoriesSubscription.cancel();
      DialogShower.showAlertDialog(
              context, "Fatto!", "La categoria è stata eliminata correttamente")
          .then((value) {
        Navigator.of(context).pop();
      });
    } else if (event is CategoriesErrorState &&
        event.event is CategoryDeleteEvent) {
      DialogShower.showAlertDialog(context, "Attenzione",
          "Ho riscontrato un errore provando ad eliminare la categoria. Riprova.");
    } else if (event is ProductCreatedSuccesfully ||
        event is ProductDeletedSuccesfully) {
      if (event is ProductDeletedSuccesfully) {
        DialogShower.showAlertDialog(context, "Fatto!",
                "Il prodotto è stato eliminato correttamente")
            .then((value) {
          updateCategory();
        });
      } else {
        updateCategory();
      }
    } else if (event is CategoriesErrorState &&
        event.event is ProductDeleteEvent) {
      DialogShower.showAlertDialog(context, "Attenzione",
          "Ho riscontrato un errore provando ad eliminare un prodotto. Riprova.");
    } else if (event is CategoriesErrorState &&
        event.event is ProductCreateEvent) {
      DialogShower.showAlertDialog(context, "Attenzione",
          "Ho riscontrato un errore provando a creare un prodotto. Riprova.");
    } else if (event is CategoriesFetched) {
      setState(() {
        myCategory = event.categories
            .firstWhere((element) => element.name == myCategory!.name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int productsInCategory = 0;
    double maxListHeight = 0;

    if(!widget.creationMode)
    {
      //Calcolo l'altezza della lista da costuire in base
      //al numero dei componenti
      productsInCategory = myCategory!.products.length;
      maxListHeight = 20 +
      (productsInCategory < 3? productsInCategory : 2.5) 
      * ProductItem.rowHeight + 
      (productsInCategory < 3? 20 * productsInCategory + 5 : 60);

      if(widget.hasPermission && productsInCategory<2)
      {
        maxListHeight += ProductItem.rowHeight + 20;
      }
    }

    return DialogPageTemplate(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500
            ),
            child: SingleChildScrollView(
              controller: _parentScrollController,
              child: NotificationListener<OverscrollNotification>(
                onNotification: (notification) => 
                scrollParentOnChildOverscroll(notification, _parentScrollController),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: const SizedBox(
                            width: double.infinity,
                            height: CategoryPage.imageSize/2,
                          )
                        ),
                        Center(
                          child: Hero(
                            tag: "Container${myCategory?.name}",
                            child: Material(
                              clipBehavior: Clip.hardEdge,
                              elevation: defaultElevation,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius:BorderRadius.circular(
                                defaultBorderRadius
                              ),
                              child: FdaLoading(
                                loadingNotifier: loading,
                                dynamicText: loadingText,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: CategoryPage.imageSize /2, 
                                    bottom: 20
                                  ),
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!widget.creationMode)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20, 
                                            right: 20
                                          ),
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.stretch,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CategoryInfo(
                                                category: myCategory!,
                                                onCountChanged: (value) {},
                                              ),
                                              if (widget.hasPermission)
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: TextButton(
                                                  onPressed: () {
                                                    DialogShower.showConfirmDenyDialog(
                                                        context,
                                                        "Eliminazione",
                                                        "Sei sicuro di voler eliminare "
                                                        "definitivamente questa categoria?",
                                                        onConfirmPressed: () {
                                                      loading.value = true;
                                                      loadingText.value = "Sto eliminando la categoria...";
                                                      _categoriesBloc.add(
                                                          CategoryDeleteEvent(
                                                              myCategory!));
                                                    });
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "Elimina",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: Colors.red),
                                                      ),
                                                      const Icon(
                                                        Icons.delete_forever,
                                                        color: Colors.red,
                                                        size:
                                                            CategoryPage.deleteIconSize,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),                                      
                                      if (!widget.creationMode &&
                                          !widget.hasPermission)
                                        const Gap(20),
                                      if (!widget.creationMode)
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: maxListHeight
                                          ),
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(10),
                                            itemCount: myCategory!.products.length +
                                              (widget.hasPermission? 1: 0),
                                            itemBuilder: (context, index) => 
                                            index < myCategory!.products.length?
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                                top: 10
                                              ),
                                              child: ProductItem(
                                                // borderRadius: BorderRadius.zero,
                                                // backgroundColor: Colors.grey.shade50,
                                                product: myCategory!.products[index],
                                                hasPermission: widget.hasPermission,
                                                onDeleteRequest: () {
                                                  DialogShower.showConfirmDenyDialog(
                                                    context, 
                                                    "Eliminazione", 
                                                    "Sei sicuro di voler "
                                                    "eliminare questo prodotto?",
                                                    confirmText: "Elimina",
                                                    denyText: "Annulla",
                                                    onConfirmPressed: (){
                                                      loading.value = true;
                                                      loadingText.value = "Sto eliminando il prodotto...";
                                                      _categoriesBloc.add(
                                                        ProductDeleteEvent(
                                                          myCategory!.products[index]
                                                        )
                                                      );
                                                    }
                                                  );
                                                },
                                              ),
                                            ):
                                            SizedBox(
                                              height: 150,
                                              child: SuperHero(
                                                tag: "",
                                                generateRoute: () => PageRouteBuilder(
                                                  opaque: false,
                                                  pageBuilder: (context,
                                                    animation,
                                                    secondaryAnimation
                                                  ) {
                                                    return const CreateProductPage();
                                                  },
                                                ),
                                                onPageReturn: (productPair) {
                                                  if (productPair != null) {
                                                    loading.value = true;
                                                    loadingText.value = "Sto creando il prodotto...";
                                                    _categoriesBloc.add(
                                                        ProductCreateEvent(
                                                      myCategory!,
                                                      productPair.$1,
                                                      productPair.$2,
                                                    ));
                                                  }
                                                },
                                                childWithHeros: AddElementWidget(
                                                  containerTag: "ProductCreate",
                                                  iconTag: "ImageChooser",
                                                  onPressed: (){},
                                                ),
                                                child: AddElementWidget(
                                                  onPressed: () {},
                                                ),
                                              ),
                                            ),
                                                 
                                          )
                                        ),
                                      if (widget.creationMode)
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Form(
                                            key: nameFormKey,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (!validateCategoryName()) {
                                                  return "Inserisci il nome, da 3 a 20 caratteri. Solo lettere.";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                  label: Text("Nome categoria")),
                                              onChanged: (value) {
                                                newCategoryName = value;
                                              },
                                            ),
                                          ),
                                        ),
                                      if (widget.creationMode)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            bottom: 20
                                          ),
                                          child: SizedBox(
                                            height: 50,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  if (validateNewCategory()) {
                                                    Navigator.of(context).pop((
                                                      newCategoryName,
                                                      newCategoryImage
                                                    ));
                                                  } else if (newCategoryImage ==
                                                      null) {
                                                    DialogShower.showAlertDialog(
                                                        context,
                                                        "Attenzione",
                                                        "Inserisci un'immagine prima di procedere");
                                                  }
                                                },
                                                child:
                                                    const Text("Crea categoria")),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: !widget.creationMode
                          ? CategoryImage(
                            tag: "Image${myCategory?.name}",
                            size: CategoryPage.imageSize,
                            imageName: widget.category!.imageName,
                          )
                          : ImageChooser(
                              heroTag: "Image${myCategory?.name}",
                              height: CategoryPage.imageSize,
                              width: CategoryPage.imageSize,
                              editable: true,
                              onImageChanged: (img) {
                                newCategoryImage = img;
                              },
                            ),
                    ),                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
