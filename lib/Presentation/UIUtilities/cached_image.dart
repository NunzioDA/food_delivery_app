import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Usufruisce di [CachedNetworkImage] dandone un'aspetto standartzzato e 
/// mettendo a disposizione il metodo [getImageProvider] per generare un 
/// provider dell'url specificato.

class FdaCachedNetworkImage extends StatelessWidget
{
  final String url;

  const FdaCachedNetworkImage({super.key, required this.url});
  
  ImageProvider getImageProvider()
  {
    return CachedNetworkImageProvider(url);
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      progressIndicatorBuilder: (context, url, progress) {
        return Align(child: CircularProgressIndicator(value: progress.progress,));
      },
    );
  }
  
}