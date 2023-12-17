import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/Pages/Templates/dialog_page_template.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/image_chooser.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/credential_validation.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

/// Questa pagina permette di creare un nuovo [Product]
/// inserendo un'immagine e tutti i dettagli necessari.
/// Qualora l'utente completi con successo la creazione,
/// restituirà il nuovo [Product] tramite [Navigator]
/// alla pagina chiamante.

class CreateProductPage extends StatefulWidget{
  static const double imageSize = 90;
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {

  XFile? image;

  String? name, description;
  double? price;

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DialogPageTemplate(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                color: Theme.of(context).dialogBackgroundColor
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: ImageChooser(
                          height: CreateProductPage.imageSize,
                          width: CreateProductPage.imageSize,
                          onImageChanged: (value) {
                            image = value;
                          },
                        ),
                      ),
                      const Gap(20),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) => !validateName(name)? 
                              "Inserire un nome dai 3 ai 20 caratteri":null,
                              decoration: const InputDecoration(
                                label: Text("Nome")
                              ),
                              onChanged: (value) => name = value,
                            ),
                            const Gap(20),
                            TextFormField(
                              validator: (value) {
                                if(value==null || value.isEmpty)
                                {
                                  return "Inserire una descrizione";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text("Descrizione")
                              ),
                              onChanged: (value) => description = value,
                            ),
                            const Gap(20),
                            TextFormField(
                              validator: (value) {
                                if(value==null || value.isEmpty)
                                {
                                  return "Inserire un prezzo";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text("Prezzo")
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                              ],
                              keyboardType: TextInputType.number,
                              onChanged: (value) => price = double.parse(value),
                            )
                          ],
                        )
                      ),
                      const Gap(20),
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: (){
                            if(formKey.currentState?.validate()??false)
                            {
                              if(image != null)
                              {
                                var product = Product(
                                  name!, 
                                  description!,
                                  price!
                                );
                  
                                Navigator.of(context).pop((product, image));
                              }
                              else{
                                DialogShower.showAlertDialog(
                                  context, 
                                  "Immagine", 
                                  "Prima di procedere inserisci un'immagine che rappresenta il prodotto."
                                );
                              }
                            }                            
                          }, 
                          child: const Text("Crea prodotto")
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}