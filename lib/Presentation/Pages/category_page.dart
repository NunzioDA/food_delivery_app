import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Category/category_info.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/Presentation/Pages/product_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_element.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/image_chooser.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPage extends StatefulWidget {
  static const double imageSize = 120;
  static const double listHeight = 500;
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

  @override
  void initState() {
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
    return Scaffold(
      backgroundColor: defaultTransparentScaffoldBackgrounColor(context),
      body: SafeArea(
        child: FdaLoading(
          loadingNotifier: loading,
          dynamicText: ValueNotifier("Sto eliminando la categoria"),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Wrap(
                children: [
                  Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(CategoryPage.imageSize / 2),
                          Hero(
                            tag: "Container${myCategory?.name}",
                            child: Material(
                              elevation: 10,
                              color: Theme.of(context).dialogBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(defaultBorderRadius),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 30, right: 20, left: 20, bottom: 20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!widget.creationMode)
                                      CategoryInfo(
                                        category: myCategory!,
                                        onCountChanged: (value) {},
                                      ),
                                    if (!widget.creationMode &&
                                        widget.hasPermission)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            DialogShower.showConfirmDenyDialog(
                                                context,
                                                "Eliminazione",
                                                "Sei sicuro di voler eliminare definitivamente questa categoria?",
                                                onConfirmPressed: () {
                                              loading.value = true;
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
                                    if (!widget.creationMode &&
                                        !widget.hasPermission)
                                      const Gap(20),
                                    if (!widget.creationMode)
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight:CategoryPage.listHeight,
                                          minHeight: 1
                                        ),
                                        child: ListView.builder(
                                          itemCount: myCategory!.products.length +
                                            (widget.hasPermission? 1: 0),
                                          itemBuilder: (context, index) => 
                                          index < myCategory!.products.length?
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20),
                                            child: ProductItem(
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
                                                    loading.value =true;
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
                                            child: AddElementWidget(
                                              onPressed: () async {
                                                var productPair =
                                                    await Navigator.of(
                                                            context)
                                                        .push(
                                                            PageRouteBuilder(
                                                  opaque: false,
                                                  pageBuilder: (context,
                                                      animation,
                                                      secondaryAnimation) {
                                                    return const CreateProductPage();
                                                  },
                                                ));
                                            
                                                if (productPair != null) {
                                                  loading.value = true;
                                                  _categoriesBloc.add(
                                                      ProductCreateEvent(
                                                    myCategory!,
                                                    productPair.$1,
                                                    productPair.$2,
                                                  ));
                                                }
                                              },
                                            ),
                                          ),
                                               
                                        )
                                      ),
                                    if (widget.creationMode) const Gap(50),
                                    if (widget.creationMode)
                                      Form(
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
                                    if (widget.creationMode) const Gap(10),
                                    if (widget.creationMode)
                                      SizedBox(
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
                        child: !widget.creationMode
                            ? Hero(
                                tag: "Image${myCategory?.name}",
                                child: SizedBox(
                                  height: CategoryPage.imageSize,
                                  width: CategoryPage.imageSize,
                                  child: FdaCachedNetworkImage(
                                    url: FdaServerCommunication.getImageUrl(
                                      myCategory!.imageName
                                    ),
                                  ),
                                ))
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
