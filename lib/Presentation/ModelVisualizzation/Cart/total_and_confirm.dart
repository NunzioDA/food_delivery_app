import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Cart/cart_content.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/side_menu.dart';
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

  bool wasOpened = false;

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
    return controller.value > 0.5;
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
    if(!SideMenuViewInherited.of(context).isWithTopBarMode)
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

    return Stack(
      fit: StackFit.expand,
      children: [
        if(isOpened())
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: close,
        ),
        Positioned(
          top: top,
          bottom: bottom,
          width: width,
          right:right,
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if(!SideMenuViewInherited.of(context).isWithTopBarMode && animation.value == 0)
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
                      borderRadius: SideMenuViewInherited.of(context).isWithTopBarMode? const BorderRadius.only(
                          topLeft: Radius.circular(defaultBorderRadius),
                          topRight: Radius.circular(defaultBorderRadius)):null,
                      boxShadow: SideMenuViewInherited.of(context).isWithTopBarMode || isOpened()? 
                      const [BoxShadow(blurRadius: 5, color: Colors.grey)] : null
                    ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: !SideMenuViewInherited.of(context).isWithTopBarMode? 20 : 5,
                      bottom: 20
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if(SideMenuViewInherited.of(context).isWithTopBarMode)
                        Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (event){
                            wasOpened = isOpened();
                          },
                          onPointerMove: (event) {
                            double screenHeight = MediaQuery.of(context).size.height + ContentVisualizerTopBar.barHeight;
                            double positionFromBottom = screenHeight - event.position.dy - 
                            TotalAndConfirm.closedPanelHeight;
                            controller.value = positionFromBottom / (widget.maxHeight - TotalAndConfirm.closedPanelHeight);
                          },
                          onPointerUp: (event){
                            if(!wasOpened && controller.value < 0.1 || 
                            wasOpened && controller.value < 0.9)
                            {
                              controller.reverse();
                            }
                            else if(wasOpened || controller.value > 0.1)
                            {
                              controller.forward();
                            }
                          },
                          child: const Center(
                            child: Icon(
                              Icons.remove
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:20.0, right: 20),
                          child: Row(
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
                              // if(SideMenuViewInherited.of(context).isWithTopBarMode)
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
                        Padding(
                          padding: const EdgeInsets.only(left:20.0, right: 20),
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: widget.onCompleteOrderRequest,
                              child: const Text("Completa l'ordine"),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
