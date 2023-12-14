import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class FdaImage 
{
  final Uint8List image;
  final String extension;
  const FdaImage(this.image, this.extension);
}

// Permette di ottimizzare le immagini dandone una risoluzione massima (FHD di default)
// e formato png, prima che queste vengano inviate al server remoto.
class FdaImageOptimizer
{ 
  static Future<FdaImage?> optimize(XFile imageFile, [int maxWidthHeigth = 1920]) async {
    var bytes = await imageFile.readAsBytes();
    
    var s = lookupMimeType(imageFile.path, headerBytes: bytes);

    if(s!= null)
    {
      String prefix = "image/";
      int index = s.indexOf(prefix);

      if(index > -1)
      {
        s = ".${s.substring(index + prefix.length)}";            
      }
      else {
        s = null;
      }
    }

    var image =  await decodeImageFromList(bytes);

    int maxDimension = max(image.width, image.height);

    Uint8List? optimizedSize = bytes;

    if(maxDimension > maxWidthHeigth || s != ".png")
    {
      s = ".png";
      ImageProvider provider = Image.memory(bytes).image;
      ResizeImage resized = ResizeImage(
        provider, 
        height: maxDimension == image.height? maxWidthHeigth : null,  
        width: maxDimension == image.width? maxWidthHeigth : null,
      );
      final Completer<Uint8List?> completer = Completer<Uint8List?>();

      resized.resolve(ImageConfiguration.empty).addListener(
        ImageStreamListener((imageInfo, synchronousCall) async{              
          final bytes = await imageInfo.image.toByteData(format: ImageByteFormat.png);
          if (!completer.isCompleted) {
            completer.complete(bytes?.buffer.asUint8List());
          }
        })
      );

      optimizedSize = await completer.future;
    }
    
    return FdaImage(optimizedSize!, s!);
  }
}