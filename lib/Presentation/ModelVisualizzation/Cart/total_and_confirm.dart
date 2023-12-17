import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/cart_content.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

/// Questo widget permette di visualizzare il totale dei prodotti 
/// attualmente in [CartBloc] e di visualizzare su richiesta il carrello
/// tramite [CartContent].
/// 
/// Il carrello verrà mostrato cliccando sull'apposito pulsante, che avvierà
/// un'animazione. Questo richiede che il widget venga usato all'interno di uno
/// [Stack] per permettere il libero spostamento tramite [Positioned].

class TotalAndConfirm extends StatefulWidget {
  static const double closedPanelHeight = 90;
  static const double closedPanelButtonSize = 60;
  static const double minPanelWidthHorizontal = 500;

  final String confirmText;
  final double maxHeight;
  final VoidCallback onCompleteOrderRequest;

  const TotalAndConfirm({
    super.key,
    required this.confirmText,
    required this.maxHeight,
    required this.onCompleteOrderRequest
    });

  @override
  State<TotalAndConfirm> createState() => TotalAndConfirmState();
}

class TotalAndConfirmState extends State<TotalAndConfirm> 
  with SingleTickerProviderStateMixin{

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100)
    )..addListener(() {setState(() {});});

    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    super.initState();
  }  

  bool isOpened()
  {
    return controller.isCompleted;
  }

  void open()
  {
    controller.forward();
  }

  void close()
  {
    controller.reverse();
  }



  @override
  Widget build(BuildContext context) {

    double? top;
    double? bottom;
    double? width;
    double? height;
    double? right;

    // Impostazione parametri di posizionamento
    if(UIUtilities.isHorizontal(context))
    {
      double screenBasedWidth = (MediaQuery.of(context).size.width / 3);
      width = screenBasedWidth < TotalAndConfirm.minPanelWidthHorizontal? 
        TotalAndConfirm.minPanelWidthHorizontal : screenBasedWidth
      + TotalAndConfirm.closedPanelButtonSize;

      if(width > MediaQuery.of(context).size.width)
      {
        width = MediaQuery.of(context).size.width;
      }

      right = (width - TotalAndConfirm.closedPanelButtonSize) * (-1 + animation.value) ;
      bottom = 0;
      top = 0;
    }
    else{
      height = widget.maxHeight;
      width = MediaQuery.of(context).size.width;
      bottom = (widget.maxHeight - TotalAndConfirm.closedPanelHeight) * (-1+ animation.value );
    }    

    return Positioned(
      top: top,
      bottom: bottom,
      width: width,
      right:right,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if(UIUtilities.isHorizontal(context))
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                if(!isOpened())
                {
                  open();
                }
                else{
                  close();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        width: 2, 
                        color: Theme.of(context).colorScheme.secondary
                      ),
                      left: BorderSide(
                        width: 2, 
                        color: Theme.of(context).colorScheme.secondary
                      ),
                      bottom: BorderSide(
                        width: 2, 
                        color: Theme.of(context).colorScheme.secondary
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(defaultBorderRadius),
                      bottomLeft: Radius.circular(defaultBorderRadius)
                    )
                  ),
                  height: TotalAndConfirm.closedPanelButtonSize,
                  width: TotalAndConfirm.closedPanelButtonSize,
                  child: Icon(
                    animation.value == 0? 
                      Icons.shopping_cart_outlined : 
                      Icons.close_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: !UIUtilities.isHorizontal(context)? const BorderRadius.only(
                      topLeft: Radius.circular(defaultBorderRadius),
                      topRight: Radius.circular(defaultBorderRadius)):null,
                  boxShadow: !UIUtilities.isHorizontal(context)? 
                  const [BoxShadow(blurRadius: 5, color: Colors.grey)] : null
                ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Totale"),
                            BlocBuilder<CartBloc, CartState>(
                              bloc: BlocProvider.of<CartBloc>(context),
                              builder: (context, state) {
                                return Text(
                                  "${getTotal(state.cart)}€",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                );
                              },
                            )
                          ],
                        ),
                        if(!UIUtilities.isHorizontal(context))
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: (){
                              if(!isOpened())
                              {
                                open();
                              }
                              else{
                                close();
                              }
                            }, 
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Text(animation.value == 0? "Carrello" : "Chiudi"),
                                  const VerticalDivider(
                                    width: 20, 
                                    thickness: 0.5, 
                                    color: Colors.white,
                                    endIndent: 0,
                                    indent: 0,
                                  ),
                                  Icon(
                                    animation.value == 0? 
                                    Icons.shopping_cart_outlined : 
                                    Icons.close_rounded,
                                    size: 20,                                                 
                                  ),
                                ],
                              ),
                            )
                          ),
                        )
                      ],
                    ),
                    if(animation.value != 0)
                    const Gap(20),
                    if(animation.value != 0)
                    const Expanded(
                      child: CartContent()
                    ),
                    if(animation.value != 0)
                    const Gap(20),
                    if(animation.value != 0)
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: widget.onCompleteOrderRequest,
                        child: const Text("Completa l'ordine"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
