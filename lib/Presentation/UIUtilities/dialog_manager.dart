import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:gap/gap.dart';

/// Classe formata da metodi statici che permettono di visualizzare
/// [AlertDialog] di diverso genere da qualunque [BuildContext].
class DialogVisualizer
{
  static const double buttonsHeight = 40;

  /// [AlertDialog] per visualizzare qualsiasi messaggio generico.
  static Future<void> showAlertDialog(
    BuildContext context, 
    String title, 
    String text, 
    {String? confirmText, VoidCallback? onConfirmPressed}
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius)
          ),
          title: Text(
            title, 
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(text),
          actions: <Widget>[
            SizedBox(
              height: buttonsHeight,
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text((confirmText != null)? confirmText : "Ok"),
                onPressed: () {
                  onConfirmPressed?.call();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// [AlertDialog] per mostrare il completamento di un task
  /// con gif animata di completamento.
  static Future<void> showTaskCompletedDialog(
    BuildContext context, 
    String task, 
    {String? confirmText, VoidCallback? onConfirmPressed}
  ) {
    AssetImage asset = const AssetImage("assets/complete.gif");
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 200
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image(image: asset),
                ),
              ),
              Text(task, textAlign: TextAlign.center,),
              const Gap(20),              
            ],
          ),
          actions: [
            SizedBox(
              height: buttonsHeight,
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text((confirmText != null)? confirmText : "Ok"),
                onPressed: () {
                  onConfirmPressed?.call();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    ).then((value) => asset.evict());
  }
  
  /// Mostra un [AlertDialog] che permette di accettare o rifiutare
  /// una proposta.
  static Future<void> showConfirmDenyDialog(
    BuildContext context, 
    String title, 
    String text, 
    {
      String? confirmText, 
      VoidCallback? onConfirmPressed, 
      String? denyText, 
      VoidCallback? onDenyPressed
    }
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius)
          ),
          title: Text(
            title, 
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(text),
          
          actions: <Widget>[
            SizedBox(
              height: buttonsHeight,
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(denyText ?? "Annulla", 
                style: const TextStyle(color: Colors.grey),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              height: buttonsHeight,
              child: ElevatedButton(
                onPressed: () {
                  onConfirmPressed?.call();
                  Navigator.of(context).pop();
                },
                child: Text(confirmText ?? "Conferma"),
              ),
            ),
          ],
        );
      },
    );
  }
}