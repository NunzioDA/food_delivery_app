import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dynamic_grid_view.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:food_delivery_app/cubit/connectivity_cubit.dart';
import 'package:food_delivery_app/cubit/delivery_info_cubit.dart';
import 'package:gap/gap.dart';

/// Questa pagina permette all'utente di completare l'ordine,
/// proponendo un riepilogo ordine tramite la classe [OrderSummary]
/// e permette di scegliere un indirizzo precedentemente usato o inserirne
/// uno nuovo, gestendo gli indirizzi con la classe [DeliveryInfoManagement]

class CompleteOrderPage extends StatefulWidget{
  static const double padding = 60;
  const CompleteOrderPage({super.key});

  @override
  State<CompleteOrderPage> createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {

  GlobalKey<_DeliveryInfoManagementState> deliveryInfoManagement = GlobalKey();  
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

  Widget infoSection()
  {
    return Padding(
      padding: UIUtilities.isHorizontal(context)? const EdgeInsets.only(
        right: 20,
        left: CompleteOrderPage.padding,
        top: CompleteOrderPage.padding,
        bottom: CompleteOrderPage.padding
      ):
      const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [                    
          Text(
            "Checkout",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            "Ci siamo quasi",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text(
            "Abbiamo bisogno delle ultime informazioni, e siamo subito da te.",
          ),
          const Gap(20),
          DeliveryInfoManagement(
            key: deliveryInfoManagement,
          ),
          const Gap(20),
          const PaymentInfoManagement()
        ],
      ),
    );
  }

  Widget summarySection()
  {
    return Padding(
      padding: UIUtilities.isHorizontal(context)? const EdgeInsets.only(
        left: 25,
        right: CompleteOrderPage.padding-5,
        top: CompleteOrderPage.padding,
        bottom: CompleteOrderPage.padding
      ):
      const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: UIUtilities.isHorizontal(context)? 400 : double.infinity
        ),
        child: OrderSummary(
          onCompleteRequest : () {
            DeliveryInfo? deliveryInfo = deliveryInfoManagement
            .currentState?.getDeliveryInfo();
            if(deliveryInfo!=null)
            {
              orderBloc.add(
                ConfirmOrderEvent(deliveryInfo)
              );
            }
          },
        ),
      ),
    );
  }
  
  /// Imposto il flex della sezione più piccola (la parte relativa 
  /// al riepilogo ordine). Risulta preferibile mantenere un valore alto
  /// in modo da aumentare la capacità di discretizzazione della funzione
  /// [_infoSectionFlex], cercando di ridurre al meglio l'errore di discretizzazione
  /// nel momento in cui la sigmoide viene trasformata in un valore di flex.
  /// 
  /// L'errore è relativo allo scarto tra il rapporto tra i valori di flex delle
  /// due sezioni, e il valore riportato dalla sigmoide.
  final int _summarySectionFlex = 1000;

  /// Crea una sigmoide con intervallo 1-2, con centro variabile
  /// e pendenza 50, che permette in base alla larghezza della finestra
  /// di asspegnare un flex alla sezione di informazioni.
  /// L'obbiettivo è quello di raddoppiare [_summarySectionFlex] per dimensioni superiori
  /// a quella indicata da [center] o restituire un valore vicino a [_summarySectionFlex]
  /// man mano che la finestra diminuisce di dimensioni.
  /// In questo modo la sezione delle informazioni sarà il doppio della sezione
  /// del riepilogo per finestre larghe, mentre saranno simili per finestre più
  /// piccole, cercando di fornire sempre il giusto spazio per visualizzare entrambe
  /// le sezioni.
  int _infoSectionFlex(double center)
  {
    var x = MediaQuery.of(context).size.width;
    double result =  (1.0/(1.0+pow(e, -(x-center)/50))) +1.0;
    return (result * _summarySectionFlex).round();
  }

  Widget contentFlex()
  {
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      direction: UIUtilities.isHorizontal(context)? 
      Axis.horizontal : Axis.vertical,
      children: [                    
        Flexible(
          flex: (UIUtilities.isHorizontal(context))? 
          _infoSectionFlex(1100): 0,
          child: Align(
            child: UIUtilities.isHorizontal(context)? 
            SingleChildScrollView(child: infoSection())
            :infoSection(),
          ),
        ),
        if(UIUtilities.isHorizontal(context))
        const VerticalDivider(
          width: 0, 
          thickness: 0.11,
          endIndent: 60,
          indent: 60,
          color: Colors.black,
        ),
        Flexible(
          flex: UIUtilities.isHorizontal(context)? _summarySectionFlex : 0,
          child: UIUtilities.isHorizontal(context)? 
          Align(child: SingleChildScrollView(child: summarySection(),)):
          summarySection(),
        ),                    
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !UIUtilities.isHorizontal(context)? SingleChildScrollView(
          // physics: UIUtilities.isHorizontal(context) ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
          child: contentFlex() 
        ) : contentFlex(),
      ),
    );
  }
}

class PaymentMethod{
  final String asset;
  final Color color;
  const PaymentMethod(this.asset, this.color);
}

class PaymentInfoManagement extends StatefulWidget{


  const PaymentInfoManagement({super.key});

  @override
  State<PaymentInfoManagement> createState() => _PaymentInfoManagementState();
}

class _PaymentInfoManagementState extends State<PaymentInfoManagement> {

  
  List<PaymentMethod> methods = [
    const PaymentMethod("paypal.png", Colors.white),
    const PaymentMethod("mastercard.png", Color(0xff374961)),
    const PaymentMethod("visa.png", Color(0xff0066B1))
  ];

  late PaymentMethod selected;

  @override
  void initState() {
    selected = methods[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Informazioni di pagamento",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800
          ),
        ),         
        const Divider(
          color: Colors.black,
          height: 10,
          thickness: 1,
        ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            elevation: defaultElevation,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DynamicGridView(
                fit: DynamicGridFit.loose,
                targetItemWidth: 150,
                aspectRatio: 2/3,
                spacing: 20,
                runSpacing: 20,
                children: methods.map((e) => 
                  GestureDetector(
                    onTap: ()=>setState(() {
                      selected = e;
                    }),
                    child: Material(
                      elevation: 5,
                      color: e.color,
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultBorderRadius),
                          border: selected==e? Border.all(
                            width: 5, 
                            color: Theme.of(context).colorScheme.secondary
                          ): null
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset("assets/icons/${e.asset}"),
                        ),
                      ),
                    ),
                  )
                ).toList(),
              ),
            ),
          ),
        ),
      ],
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
  late ConnectivityCubit connectivityCubit;
  late StreamSubscription connectivitySubscription;

  late AnimationController _controllerToAddInfo;
  late Animation<double> animationToAddInfo;
  late Animation<double> animationToAddInfoInverse;


  @override
  void initState() {
    formKey = GlobalKey();
    deliveryInfoCubit = DeliveryInfoCubit(BlocProvider.of<UserBloc>(context));
    deliveryInfoCubit.fetchDeliveryInfos();

    connectivityCubit = BlocProvider.of<ConnectivityCubit>(context);
    connectivitySubscription = connectivityCubit.stream.listen(
      (event) {
        if(event is Connected && event.restored)
        {
          deliveryInfoCubit.fetchDeliveryInfos();
        }
      },
    );

    _controllerToAddInfo = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 100)
    );

    animationToAddInfo = Tween<double>(begin: 0, end: 1).animate(_controllerToAddInfo);
    animationToAddInfoInverse = Tween<double>(begin: 1, end: 0).animate(_controllerToAddInfo);    


    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Informazioni di consegna",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800
          ),
        ),         
        const Divider(
          color: Colors.black,
          height: 10,
          thickness: 1,
        ),
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
                    animationToAddInfo : animationToAddInfoInverse,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Inserisci di seguito le nuove informazioni di consegna e"
                      " procedi al pagamento.",
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Material(
                        elevation: defaultElevation,
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                        color: Colors.grey.shade200,
                        clipBehavior: Clip.hardEdge,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if(state is DeliveryInfoStateFetched && state.myDeliveryInfos.isNotEmpty)
              SizeTransition(
                sizeFactor: animationToAddInfoInverse,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Seleziona le tue informazioni di consegna",
                    ),
                    const Gap(20),
                    ChooseOldAddress(
                      state: state,
                      onSelectionChanged:(selected) =>
                        deliveryInfoCubit.selectDeliveryInfo(selected),
                    ),
                  ],
                ),
              ),
              if(state is DeliveryInfoStateFetched && state.myDeliveryInfos.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: (){
                    if(_controllerToAddInfo.isCompleted && deliveryInfoCubit.state is DeliveryInfoStateFetched)
                    {
                      deliveryInfoCubit.selectDeliveryInfo(
                        (deliveryInfoCubit.state as DeliveryInfoStateFetched).myDeliveryInfos[0]
                      );
                      _controllerToAddInfo.reverse();
                    }
                    else{
                      deliveryInfoCubit.selectDeliveryInfo(null);
                      _controllerToAddInfo.forward();
                    }
                  }, 
                  child: BlocBuilder(
                    bloc: deliveryInfoCubit,
                    buildWhen: (previous, current) => current is DeliveryInfoSelectionChanged,
                    builder: (context, state) => 
                    Text((deliveryInfoCubit.state as DeliveryInfoSelectionChanged).selected != null? 
                      "Nuovo indirizzo" : 
                      "Scegli tra i tuoi indirizzi"
                    ),
                  )
                ),
              )
            ]
          )
        )
      ],
    );
  }
}

class ChooseOldAddress extends StatefulWidget
{
  final DeliveryInfoStateFetched state;
  final void Function(DeliveryInfo selected) onSelectionChanged;
  const ChooseOldAddress({
    super.key, 
    required this.state,
    required this.onSelectionChanged
  });

  @override
  State<ChooseOldAddress> createState() => _ChooseOldAddressState();
}

class _ChooseOldAddressState extends State<ChooseOldAddress> 
with SingleTickerProviderStateMixin
{
  late AnimationController _controllerExpandOldInfo;
  late Animation<double> _animationExpandOldInfo;

  @override
  void initState() {
    _controllerExpandOldInfo = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 100)
    )..addListener(() {setState(() {});});
    _animationExpandOldInfo = Tween<double>(begin: 0, end: 1).animate(_controllerExpandOldInfo);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [        
        Padding(
          padding: const EdgeInsets.only(left:20, right: 20),
          child: Material(
            elevation: defaultElevation,
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Spediremo a questo indirizzo",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),   
                  if(widget.state is DeliveryInfoSelectionChanged && 
                  (widget.state as DeliveryInfoSelectionChanged).selected != null)                     
                  DeliveryInfoWidget(deliveryInfo: (widget.state as DeliveryInfoSelectionChanged).selected!),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [                  
                      Expanded(
                        child: AutoSizeText(
                          "Indirizzi recenti",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: pi/2 + (_animationExpandOldInfo.value * pi),
                        child: IconButton(
                          onPressed: (){
                            if(!_controllerExpandOldInfo.isCompleted)
                            {
                              _controllerExpandOldInfo.forward();
                            }
                            else{
                              _controllerExpandOldInfo.reverse();
                            }
                          },
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(10),                      
        SizeTransition(
          sizeFactor: _animationExpandOldInfo,
          axis: Axis.vertical,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsets.only(left:20, right: 20, bottom: 20),
            child: Material(
              clipBehavior: Clip.hardEdge,
              elevation: 5,
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: widget.state.myDeliveryInfos.length<3?
                  widget.state.myDeliveryInfos.length * DeliveryInfoWidget.height:
                  3 * DeliveryInfoWidget.height,
                  child: ListView.builder(
                    itemCount: widget.state.myDeliveryInfos.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _controllerExpandOldInfo.reverse();
                            widget.onSelectionChanged(widget.state.myDeliveryInfos[index]);
                          },
                          child: DeliveryInfoWidget(
                            deliveryInfo: widget.state.myDeliveryInfos[index],
                          ), 
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(10), 
      ],
    );
  }
}


class DeliveryInfoWidget extends StatelessWidget{
  static const double height = 85;
  final DeliveryInfo deliveryInfo;
  const DeliveryInfoWidget({
    super.key,
    required this.deliveryInfo
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            deliveryInfo.intercom,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            deliveryInfo.city          
          ),
          Text(
           "${deliveryInfo.address}, ${deliveryInfo.houseNumber}"
          )
        ],
      ),
    );
  }
  
}


class OrderSummary extends StatelessWidget{
  final VoidCallback onCompleteRequest;
  const OrderSummary({
    super.key,
    required this.onCompleteRequest
  });

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = BlocProvider.of<CartBloc>(context);
    return Material(
      elevation: defaultElevation,
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Align(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: !UIUtilities.isHorizontal(context)? 400 : double.infinity
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,  
              mainAxisAlignment: MainAxisAlignment.spaceBetween,    
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [    
                Text(
                  "Riepilogo",
                  style: Theme.of(context).textTheme.titleLarge,
                ),    
                const Gap(20),
                Column(
                  mainAxisSize: MainAxisSize.min,  
                  children: [
                    ...cartBloc.state.cart.keys.map(
                      (key) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CartEntryItem(
                            product: key, 
                            count: cartBloc.state.cart[key]!
                          ),
                          const Divider(
                            color: Colors.black,
                            height: 1,
                            thickness: 0.1,
                          )
                        ],
                      )
                    ),
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
                ),
                const Gap(20),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onCompleteRequest, 
                    child: const Text("Paga")
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  product.description,
                ),
              ],
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
      ),
    );
  }
}