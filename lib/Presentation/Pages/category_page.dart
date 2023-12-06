import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Utilities/image_chooser.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPage extends StatefulWidget{
  static const double imageSize = 90;
  static const double listHeight = 500;

  final bool creationMode;
  final bool hasPermission;
  final ProductsCategory? category;

  const CategoryPage({
    super.key, 
    this.category,
    required this.hasPermission,
    this.creationMode = false
  }) : assert((category != null) != creationMode);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  String? newCategoryName;
  XFile? newCategoryImage;
  GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();

  bool validateCategoryName()
  {
    return newCategoryName != null && newCategoryName!.isNotEmpty;
  }

  bool validateNewCategory()
  {
    bool? result = nameFormKey.currentState?.validate();
    return newCategoryImage != null &&  result!= null  && result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withAlpha(110),
      body: SafeArea(
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
                        const Gap(CategoryPage.imageSize/2),
                        Hero(
                          tag: "Container${widget.category?.name}",
                          child: Material(
                            elevation: 10,
                            color: Theme.of(context).dialogBackgroundColor,
                            borderRadius: BorderRadius.circular(defaultBorderRadius),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30, 
                                right: 20, 
                                left: 20, 
                                bottom: 20
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [         
                                  if(!widget.creationMode)                       
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        widget.category!.name,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      if(widget.hasPermission)
                                      GestureDetector(
                                        onTap: (){

                                        },
                                        child: const Icon(
                                          Icons.delete_forever, 
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                  if(!widget.creationMode)
                                  Text("${widget.category!.products.length} prodotti"),
                                  if(!widget.creationMode)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: CategoryPage.listHeight,
                                      minHeight: 1
                                    ),
                                    child: ListView.builder(
                                      itemCount: widget.category!.products.length,
                                      itemBuilder: (context, index) {
                                        return Text(widget.category!.products[index].name);
                                      },
                                    )
                                  ),
                                  if(widget.creationMode)
                                  const Gap(50),
                                  if(widget.creationMode)
                                  Form(
                                    key: nameFormKey,
                                    child: TextFormField(                                  
                                      validator: (value){
                                        if(!validateCategoryName())
                                        {
                                          return "Inserisci il nome, da 3 a 20 caratteri. Solo lettere.";
                                        }
                                        else{
                                          return null;
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        label: Text("Nome categoria")
                                      ),       
                                      onChanged: (value){
                                        newCategoryName = value;
                                      },
                                    ),
                                  ),
                                  if(widget.creationMode)
                                  const Gap(10),
                                  if(widget.creationMode)
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: (){
                                        if(validateNewCategory())
                                        {
                                          Navigator.of(context).pop(
                                            (newCategoryName, newCategoryImage)
                                          );
                                        }
                                        else if(newCategoryImage == null)
                                        {
                                          // Inserisci un'immagine
                                        }
                                      }, 
                                      child: const Text("Crea categoria")
                                    ),
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
                      child: !widget.creationMode? Hero(
                        tag: "Image${widget.category?.name}",
                        child: const Icon(
                          Icons.piano,
                          size: CategoryPage.imageSize,
                        )                      
                      ) :
                      ImageChooser(       
                        heroTag: "Image${widget.category?.name}",    
                        height: CategoryPage.imageSize,
                        width: CategoryPage.imageSize,
                        editable: true,
                        onImageChanged: (img){
                          newCategoryImage = img;
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}