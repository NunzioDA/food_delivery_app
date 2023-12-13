import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:gap/gap.dart';


class DialogOption
{
  final IconData? icon;
  final String? name;
  final Color? color;
  final Widget? child;
  final dynamic value;

  const DialogOption({this.name,this.child, this.value, this.color, this.icon})
    : assert(child != null || name != null);
} 

class DialogShower
{

  static Future<void> showAlertDialog(BuildContext context, String title, String text, {String? confirmText, VoidCallback? onConfirmPressed}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title, 
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text((confirmText != null)? confirmText : "Ok"),
              onPressed: () {
                onConfirmPressed?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showTaskCompletedDialog(BuildContext context, String task, {String? confirmText, VoidCallback? onConfirmPressed}) {
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image(image: asset),
              ),
              Text(task, textAlign: TextAlign.center,),
              const Gap(20),              
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text((confirmText != null)? confirmText : "Ok"),
              onPressed: () {
                onConfirmPressed?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((value) => asset.evict());
  }

  static Future<void> showConfirmDenyDialog(BuildContext context, String title, String text, {String? confirmText, VoidCallback? onConfirmPressed, String? denyText, VoidCallback? onDenyPressed}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title, 
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(text),
          
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(denyText ?? "Annulla", 
              style: const TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                onConfirmPressed?.call();
                Navigator.of(context).pop();
              },
              child: Text(confirmText ?? "Conferma"),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showOptionsDialog(BuildContext context, String title, String description, List<DialogOption> options,{ValueChanged<dynamic>? onChoose}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              GestureDetector(
                onTap: ()=> Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10,),
              Text(
                title, 
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(            
                child: Wrap(
                  children: [
                    Text(description),
                    // const SizedBox(width: 10,),
                    Wrap(
                      children: options.map((e) => 
                        TextButton(
                          onPressed: (){
                            // print("premuto");
                            Navigator.of(context).pop();
                            onChoose?.call(e.value);
                          }, 
                          child: Row(
                            children: [
                              if(e.icon != null)
                              Icon(
                                e.icon,
                                color: e.color,
                              ),
                              if(e.icon != null)
                              const SizedBox(width: 10,),
                              if(e.child == null)
                              Text(
                                e.name!,
                                style: TextStyle(color: e.color),
                              ),
                              if(e.child != null)
                              e.child!,
                            ],
                          )
                        )
                      ).toList()
                    ),
                  ],
                ),
              ),
            ),
          ),          
        );
      },
    );
  }
  
  

//   static Future<void> showTextFieldDialog(
//     BuildContext context, 
//     String title, 
//     String description, 
//     String valueDescription, 
//     GenericCallBack<String?> onValueConfirmed, 
//     {
//       String? confirmText, 
//       String? discardText, 
//       TextInputType? keyboardType,
//       List<TextInputFormatter>? inputFormatters,
//       String? Function(String? string)? validator, 
//     })
//   {
//     GlobalKey<FormState> textKey = GlobalKey();
//     String? inputValue;
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AntiPop(
//           child: AlertDialog(
//             title: Text(title, style: TextContent.titleStyle,),
//             content: Wrap(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,      
//                   children: [
//                     Text(description, textAlign: TextAlign.left,),
//                     const SizedBox(height: 20,),
//                     Form(
//                       key: textKey,
//                       child: TextFormField(
//                         validator: validator,
//                         keyboardType: keyboardType,
//                         inputFormatters: inputFormatters,
//                         decoration: InputDecoration(
//                           labelText: valueDescription
//                         ),
//                         onChanged: (value) => inputValue = value,
//                       ),
//                     ),
//                   ],
//                 ),
//               ]
//             ),
//             actionsPadding: const EdgeInsets.only(right: 20, bottom: 15),
//             actions: <Widget>[
//               TextButton(
//                 style: TextButton.styleFrom(
//                   textStyle: Theme.of(context).textTheme.labelLarge,
//                 ),
//                 child: Text(
//                   (discardText != null)? 
//                     discardText : 
//                     "Annulla", 
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               BamsButton(          
//                 buttonHeight: 35,      
//                 text: (confirmText != null)? confirmText : "Conferma",
//                 onPressed: () {
//                   if(validator == null || textKey.currentState!.validate())
//                   {
//                     Navigator.of(context).pop();
//                     onValueConfirmed.call(inputValue);
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
}