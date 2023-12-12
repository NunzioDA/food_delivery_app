import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

class CompleteOrderPage extends StatelessWidget{
  const CompleteOrderPage({super.key});

  @override
  Widget build(BuildContext context) {

    GlobalKey<FormState> formKey = GlobalKey();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,               
                  children: [
                    const OrderSummary(),
                    const Gap(20),
                    AddressManagement(
                      formKey: formKey,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: (){
                    if(formKey.currentState?.validate() ?? false)
                    {
                      // BlocProvider.of<CartBloc>(context).add(
                        
                      // );
                    }
                  },
                  child: const Text("Conferma l'ordine")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

class AddressManagement extends StatelessWidget{
  final GlobalKey<FormState> formKey;
  const AddressManagement({
    super.key,
    required this.formKey
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Inserisci un indirizzo"),
        Form(
          key: formKey,
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
          ),
        )
      ],
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