import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:gap/gap.dart';

class CompleteOrderPage extends StatefulWidget{
  const CompleteOrderPage({super.key});

  @override
  State<CompleteOrderPage> createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {

  GlobalKey<_DeliveryInfoManagementState> deliveryInfoManaement = GlobalKey();
  late OrderBloc orderBloc;
  late StreamSubscription orderSubscription;

  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);
    orderSubscription = orderBloc.stream.listen((event) { 
      if(event is OrderPlaced)
      {
        DialogShower.showTaskCompletedDialog(
          context, 
          "L'ordine è stato completato con successo"
        ).then((value) {
          BlocProvider.of<CartBloc>(context).add(const FetchCart());
          Navigator.of(context).pop();
        });
      }
      else if(event is OrderError && event.event is ConfirmOrderEvent){
        DialogShower.showAlertDialog(
          context, 
          "Attenzione", 
          "Si è verificato un problema con il tuo ordine. Riprova."
        );
        debugPrint(event.error);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    orderSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 80,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,               
                    children: [
                      const OrderSummary(),
                      const Gap(20),
                      DeliveryInfoManagement(
                        key: deliveryInfoManaement,
                      ),
                    ],
                  ),
                ),
              ),
            ),            
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (){
                      DeliveryInfo? deliveryInfo = deliveryInfoManaement
                                              .currentState?.getDeliveryInfo();
                      if(deliveryInfo!=null)
                      {
                        orderBloc.add(
                          ConfirmOrderEvent(deliveryInfo)
                        );
                      }
                    },
                    child: const Text("Conferma l'ordine")
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DeliveryInfoManagement extends StatefulWidget {

  const DeliveryInfoManagement({
    super.key,
  });

  @override
  State<DeliveryInfoManagement> createState() => _DeliveryInfoManagementState();
}

class _DeliveryInfoManagementState extends State<DeliveryInfoManagement> {

  String? name;
  String? city;
  String? address;
  String? houseNumber;

  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    formKey = GlobalKey();
    super.initState();
  }


  DeliveryInfo? getDeliveryInfo()
  {
    if(formKey.currentState?.validate() ?? false)
    {
      return DeliveryInfo(city!, name!, address!, houseNumber!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Informazioni di consegna",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(10),
            const Text(
              "Inserisci di seguito le tue informazioni di consegna",
            ),
            const Gap(20),
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty)
                      {
                        return "Inserisci un nome";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      label: Text("Nome sul citofono")
                    ),
                    onChanged: (value) => name = value,
                  ),
                  const Gap(20),
                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty)
                      {
                        return "Inserisci una città";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      label: Text("Città")
                    ),
                    onChanged: (value) => city = value,
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "Inserisci un indirizzo";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            label: Text("Indirizzo")
                          ),
                          onChanged: (value) => address = value,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "Inserisci n.civ";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            label: Text("N.civ")
                          ),
                          onChanged: (value) => houseNumber = value,
                        ),
                      ),                      
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class OrderSummary extends StatelessWidget{
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = BlocProvider.of<CartBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Riepilogo ordine",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(10),
        ...cartBloc.state.cart.keys.map(
          (key) => CartEntryItem(
            product: key, 
            count: cartBloc.state.cart[key]! 
          )
        ).toList(),
        const Divider(color: Colors.black,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Totale",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "${getTotal(cartBloc.state)}€",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ),
      ],
    );
  }

}

class CartEntryItem extends StatelessWidget{
  final Product product;
  final int count;
  const CartEntryItem({
    super.key,
    required this.product,
    required this.count
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.titleSmall,
          )
        ),
        Text(
          "${product.price}€",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color:Colors.black
          )
        ),
        const Gap(5),
        Text("x$count")
      ],
    );
  }
}