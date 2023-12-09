import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Pages/image_show.dart';
import 'package:food_delivery_app/Presentation/Pages/product_page.dart';
import 'package:food_delivery_app/Presentation/Pages/to_visualizer_bridge.dart';
import 'package:food_delivery_app/Presentation/Utilities/add_element.dart';
import 'package:food_delivery_app/Presentation/Utilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/Utilities/category_info.dart';
import 'package:food_delivery_app/Presentation/Utilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/Utilities/image_chooser.dart';
import 'package:food_delivery_app/Presentation/Utilities/loading.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/cubit/add_remove_counter_cubit.dart';
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
  late StreamSubscription subscription;

  ProductsCategory? myCategory;

  ValueNotifier<bool> loading = ValueNotifier(false);

  bool validateCategoryName() {
    return newCategoryName != null && newCategoryName!.isNotEmpty;
  }

  bool validateNewCategory() {
    bool? result = nameFormKey.currentState?.validate();
    return newCategoryImage != null && result != null && result;
  }

  @override
  void initState() {    

    myCategory = widget.category;

    _categoriesBloc = BlocProvider.of<CategoriesBloc>(context);
    subscription = _categoriesBloc.stream.listen((event) {
      loading.value = false;
      if (event is CategoryDeletedSuccesfully) {
        DialogShower.showAlertDialog(
          context, 
          "Fatto!",
          "La categoria è stata eliminata correttamente"
        ).then((value) => Navigator.of(context).pop());
      } else if (event is CategoriesErrorState &&
          event.event is CategoryDeleteEvent) {
        DialogShower.showAlertDialog(
          context, 
          "Attenzione",
          "Ho riscontrato un errore provando ad eliminare la categoria. Riprova."
        );
      }
      else if(event is ProductCreatedSuccesfully)
      {
        _categoriesBloc.add(const CategoriesFetchEvent());
      }
      else if(event is CategoriesFetched)
      {
        setState(() {
          myCategory = event.categories.firstWhere(
            (element) => element.name == myCategory!.name
          );
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withAlpha(110),
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
                                      onCountChanged: (value){},
                                    ),
                                    if (!widget.creationMode && widget.hasPermission)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: (){
                                          DialogShower.showConfirmDenyDialog(
                                            context, 
                                            "Eliminazione", 
                                            "Sei sicuro di voler eliminare definitivamente questa categoria?",
                                            onConfirmPressed: ()
                                             => _categoriesBloc.add(CategoryDeleteEvent(myCategory!)),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Elimina",
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Colors.red
                                              ),
                                            ),
                                            const Icon(
                                              Icons.delete_forever,
                                              color: Colors.red,
                                              size: CategoryPage.deleteIconSize,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!widget.creationMode && !widget.hasPermission) 
                                    const Gap(20),
                                    if (!widget.creationMode)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxHeight:CategoryPage.listHeight,
                                          minHeight: 1
                                      ),
                                      child: GridView.count(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.75,
                                        children: [
                                          ...myCategory!.products
                                            .map((product) => Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: ProductItem(
                                                  product: product
                                                ),
                                            )
                                            ).toList(),
                                          if(widget.hasPermission)
                                          AddElementWidget(
                                            onPressed: () async {
                                              var productPair = await Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  opaque: false,
                                                  pageBuilder: (context, animation, secondaryAnimation) {
                                                    return ProductPage();
                                                  },
                                                )
                                              );

                                              if(productPair != null)
                                              {
                                                _categoriesBloc.add(
                                                  ProductCreateEvent(
                                                    myCategory!, 
                                                    productPair.$1, 
                                                    productPair.$2,
                                                  )
                                                );
                                              }
                                            },
                                          )
                                        ]
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
                                        myCategory!.imageName),
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

class ProductItem extends StatefulWidget {
  static const double imageSize = 80;

  final Product product;
  const ProductItem({super.key, required this.product});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

  late AddRemoveCounterCubit addRemoveCounterCubit;

  @override
  void initState() {
    addRemoveCounterCubit = AddRemoveCounterCubit();
    cartBloc = BlocProvider.of<CartBloc>(context);

    // init product count
    int? count = cartBloc.state.products[widget.product];
    addRemoveCounterCubit.changeCounter(count ?? 0);

    cartSubscription = cartBloc.stream.listen((event) { 
      if(event is CartProductAdded && event.addedProduct == widget.product)
      {
        int count = event.products[widget.product]!;
        addRemoveCounterCubit.changeCounter(count);
      }
      else if(event is CartProductRemoved && event.removedProduct == widget.product)
      {
        int? count = event.products[widget.product];
        addRemoveCounterCubit.changeCounter(count ?? 0);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    cartSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).dialogBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SizedBox(
          //   height: ProductItem.imageSize,
          //   child: GestureDetector(
          //     onTap: (){
          //       Navigator.of(context).push(
          //         PageRouteBuilder(
          //           opaque: false,
          //           pageBuilder: (context, animation, secondaryAnimation) => ImageVisualizer(
          //             image: FdaCachedNetworkImage(
          //               url: FdaServerCommunication.getImageUrl(widget.product.imageName)
          //             ).getImageProvider(),
          //             heroTag: widget.product.name,
          //           ),
          //         )
          //       );
          //     },
          //     child: FdaCachedNetworkImage(
          //       url: FdaServerCommunication.getImageUrl(widget.product.imageName)
          //     ),
          //   ),
          // ),
          SizedBox(
            height: ProductItem.imageSize,
            child: ZoomableImage(
              provider: FdaCachedNetworkImage(
                url: FdaServerCommunication.getImageUrl(widget.product.imageName)
              ).getImageProvider(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.left,
                  ),
                  Expanded(
                    child: Text(
                      widget.product.description,
                    ),
                  ),
                  Text(
                    "${widget.product.price}€",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: BlocProvider(
                        create: (context) => addRemoveCounterCubit,
                        child: AddRemove(
                          onAddPressed: () {
                            cartBloc.add(AddProductToCart(widget.product));
                          },
                          onRemovePressed: () {
                            cartBloc.add(RemoveProductFromCart(widget.product));
                          },
                        ),
                      )
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddRemove extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onRemovePressed;

  const AddRemove({
    super.key,
    required this.onAddPressed,
    required this.onRemovePressed,
  });

  Widget createButton(
      {required BuildContext context,
      required Color backgroundColor,
      required Color borderColor,
      required Color iconColor,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        // border: Border.all(color: Theme.of(context).primaryColor),
        color: backgroundColor,
        child: InkWell(
          onTap: onPressed.call,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: iconColor,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        createButton(
            context: context,
            backgroundColor: Colors.white,
            borderColor: Theme.of(context).primaryColor,
            iconColor: Theme.of(context).primaryColor,
            icon: Icons.remove,
            onPressed: onRemovePressed.call),
        const Gap(10),
        BlocBuilder<AddRemoveCounterCubit, AddRemoveCounterState>(
          bloc: BlocProvider.of<AddRemoveCounterCubit>(context),
          builder: (context, state) {
            return Text("${(state as AddRemoveNewCounterState).count}x");
          },
        ),
        const Gap(10),
        createButton(
            context: context,
            backgroundColor: Theme.of(context).primaryColor,
            borderColor: Colors.transparent,
            iconColor: Colors.white,
            icon: Icons.add,
            onPressed: onAddPressed.call),
      ],
    );
  }
}
