import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Pages/image_show.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:image_picker/image_picker.dart';

/// Widget che permette di slezionare un'immagine dalla galleria/file system
/// del dispositivo tramite [ImagePicker].
/// Permette inolte di visualizzare un immagine o widget di background di default
/// prima che l'immagine venga effettivamente selezionata.
/// Può entrare in modalità modifica [editable], dove se non è in modalità modifica
/// si comporterà come una normale immagine.
/// Altrimenti visualizzera un pulsante che permetterà all'utente di aprire
/// [ImagePicker] e selezionare l'immagine come [XFile].

class ImageChooser extends StatefulWidget
{
  final double? width;
  final double? height;
  final bool editable;
  final ImageProvider? defaultImage;
  final Widget? defaultBackground;
  final ValueChanged<XFile>? onImageChanged;
  final String? heroTag;
  final BoxShape shape;
  const ImageChooser({
    super.key, 
    this.height, 
    this.width, 
    this.defaultImage, 
    this.defaultBackground,
    this.editable = true, 
    this.onImageChanged,
    this.heroTag,
    this.shape = BoxShape.rectangle})
  : assert(defaultBackground == null || defaultImage == null);

  @override
  State<ImageChooser> createState() => _ImageChooserState();
}

class _ImageChooserState extends State<ImageChooser> {

  String heroTag = "ImgChooser";
  XFile? myImage;

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
    );
    
    if (pickedFile != null) {
        setState(() {
          myImage = pickedFile;
          widget.onImageChanged?.call(myImage!);
        });
    }
  }

  @override
  void initState() {
    if(widget.heroTag == null)
    {
      int micros = DateTime.now().microsecondsSinceEpoch ;
      heroTag += micros.toString();
    }
    else{
       heroTag = widget.heroTag!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag, 
      child: Material(
        child: GestureDetector(
          onTap: (){
            late ImageProvider? provider;
            
            if(myImage != null || 
              widget.defaultImage != null ||
              (
                widget.defaultBackground != null 
                && widget.defaultBackground is FdaCachedNetworkImage
              )
             )
            {
              provider = 
              (myImage != null)? 
                (kIsWeb)? 
                  Image.network(
                    myImage!.path, 
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ).image : 
                  Image.file(
                    File(myImage!.path), 
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ).image
                : widget.defaultImage;
        
                if(provider != null || widget.defaultBackground is FdaCachedNetworkImage)
                {
                  
                  Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) => ImageVisualizer(
                      image: provider ?? (widget.defaultBackground as FdaCachedNetworkImage).getImageProvider(),
                      heroTag: heroTag,
                    ),
                  ));
                }        
            }
           
          },
          child: Container(
            color: myImage!= null || widget.defaultImage != null ? 
                    Colors.transparent : 
                    Colors.grey.shade100, 
            width: widget.width,
            height: widget.height,        
            child: Stack(
              children: [
                const SizedBox(width: double.infinity,height: double.infinity,),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    shape: widget.shape,
                  ),
                  child: Stack(
                    children: [
                      if(myImage != null && kIsWeb)
                      Image.network(
                        myImage!.path, 
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      if(myImage != null && !kIsWeb)
                      Image.file(
                        File(myImage!.path), 
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      if(myImage == null && widget.defaultImage != null)
                      Image(
                        image: widget.defaultImage!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      if(myImage == null && widget.defaultBackground != null)
                      widget.defaultBackground!,
                    ],
                  ),
                ),
                if(widget.editable)
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(150),
                        ),
                        onPressed: () => _getFromGallery(),
                        child: Icon(
                          myImage == null && widget.defaultImage == null &&  widget.defaultBackground == null?
                          Icons.add : Icons.edit, 
                          color: Colors.white,
                        ),
                      ),                  
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          color: Theme.of(context).primaryColor.withAlpha(150),
                        ),
                        child: Text(
                          myImage == null && widget.defaultImage == null &&  widget.defaultBackground == null? 
                            "Aggiungi immagine" : "Modifica immagine", 
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                )          
              ],
            ),
          ),
        ),
      ),
    );
  }
}