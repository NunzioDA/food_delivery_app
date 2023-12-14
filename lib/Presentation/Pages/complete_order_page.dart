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
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:food_delivery_app/cubit/delivery_info_cubit.dart';
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
                      
                      print(deliveryInfo);
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

class _DeliveryInfoManagementState extends State<DeliveryInfoManagement> 
  with SingleTickerProviderStateMixin{

  String? name;
  String? city;
  String? address;
  String? houseNumber;

  late GlobalKey<FormState> formKey;
  late DeliveryInfoCubit deliveryInfoCubit;
  
  late AnimationController _controller;
  late Animation<double> animation;
  late Animation<double> animationInverse;

  @override
  void initState() {
    formKey = GlobalKey();
    deliveryInfoCubit = DeliveryInfoCubit(BlocProvider.of<UserBloc>(context));
    deliveryInfoCubit.fetchDeliveryInfos();

    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 100)
    );
    animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    animationInverse = Tween<double>(begin: 1, end: 0).animate(_controller);

    super.initState();
  }


  DeliveryInfo? getDeliveryInfo()
  {
    if(deliveryInfoCubit.state is DeliveryInfoSelectionChanged && 
    (deliveryInfoCubit.state as DeliveryInfoSelectionChanged).selected != null)
    {
      
      return (deliveryInfoCubit.state as DeliveryInfoSelectionChanged).selected;
    }
    
    if(formKey.currentState?.validate() ?? false)
    {
      return DeliveryInfo(city!, name!, address!, houseNumber!);
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Informazioni di consegna",
              style: Theme.of(context).textTheme.titleMedium,
            ),           
            // if(widget.previews.isEmpty)
            BlocConsumer<DeliveryInfoCubit, DeliveryInfoState>(
              bloc: deliveryInfoCubit,
              listener: (context, state) {
                if(state is DeliveryInfoError)
                {
                  DialogShower.showAlertDialog(
                    context, 
                    "Attenzione", 
                    "Non è stato possibile ottenere le tue informazioni di consegna"
                  );
                  debugPrint(state.error);
                }
                else if(state is DeliveryInfoStateFetched && 
                state is! DeliveryInfoSelectionChanged &&
                state.myDeliveryInfos.isNotEmpty)
                {
                  deliveryInfoCubit.selectDeliveryInfo(state.myDeliveryInfos[0]);
                }
              },
              buildWhen: (previous, current) => current is! DeliveryInfoSelectionChanged ||
                current.selected != null,
              builder: (context, state) => 
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                  SizeTransition(
                    sizeFactor: 
                      state is DeliveryInfoStateFetched && state.myDeliveryInfos.isNotEmpty?
                        animation : animationInverse,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Inserisci di seguito le tue informazioni di consegna",
                          ),
                          const Gap(10),
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
                    ),
                  ),
                  if(state is DeliveryInfoStateFetched && state.myDeliveryInfos.isNotEmpty)
                  SizeTransition(
                    sizeFactor: animationInverse,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Seleziona le tue informazioni di consegna",
                        ),
                        const Gap(10),
                        Text(
                          "Spediremo a questo indirizzo",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if(state is DeliveryInfoSelectionChanged && state.selected != null) 
                        DeliveryInfoWidget(deliveryInfo: state.selected!),
                        const Gap(20),
                        Text(
                          "Indirizzi recenti",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(10),                      
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: state.myDeliveryInfos.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () => deliveryInfoCubit.selectDeliveryInfo(state.myDeliveryInfos[index]),
                                child: DeliveryInfoWidget(
                                  deliveryInfo: state.myDeliveryInfos[index],
                                )
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(state is DeliveryInfoStateFetched && state.myDeliveryInfos.isNotEmpty)
                  TextButton(
                    onPressed: (){
                      if(_controller.isCompleted)
                      {
                        _controller.reverse();
                      }
                      else{
                        deliveryInfoCubit.selectDeliveryInfo(null);
                        _controller.forward();
                      }
                    }, 
                    child: Text("Nuovo indirizzo")
                  )
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}

class DeliveryInfoWidget extends StatelessWidget{
  final DeliveryInfo deliveryInfo;
  const DeliveryInfoWidget({
    super.key,
    required this.deliveryInfo
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          deliveryInfo.intercom,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          "${deliveryInfo.city}, "
          "${deliveryInfo.address}, "
          "${deliveryInfo.houseNumber}"
        ),
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
              "${getTotal(cartBloc.state.cart)}€",
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