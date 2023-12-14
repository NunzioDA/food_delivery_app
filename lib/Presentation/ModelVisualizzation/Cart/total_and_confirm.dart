import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/cart_content.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';

/// Questo widget permette di visualizzare il totale dei prodotti 
/// attualmente in [CartBloc] e di visualizzare su richiesta il carrello
/// tramite [CartContent].
/// 
/// Il carrello verrà mostrato cliccando sull'apposito pulsante, che avvierà
/// un'animazione. Questo richiede che il widget venga usato all'interno di uno
/// [Stack] per permettere il libero spostamento tramite [Positioned].

class TotalAndConfirm extends StatefulWidget {
  static const double closedPanelHeight = 90;

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
    return Positioned(
      bottom: -widget.maxHeight + TotalAndConfirm.closedPanelHeight + 
      (animation.value * (widget.maxHeight - TotalAndConfirm.closedPanelHeight)),
      width: MediaQuery.of(context).size.width,
      height: widget.maxHeight ,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(defaultBorderRadius),
                topRight: Radius.circular(defaultBorderRadius)),
            boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.grey)]),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  ElevatedButton(
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
                  )
                ],
              ),
              if(animation.value != 0)
              Expanded(
                child: CartContent(
                  onCompleteOrderRequest: widget.onCompleteOrderRequest,
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
