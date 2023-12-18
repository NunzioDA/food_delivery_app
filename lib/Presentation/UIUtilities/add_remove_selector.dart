import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:gap/gap.dart';

/// Questo widget si basa su [Bloc]. Permette di visualizzare un selettore
/// per aumentare o ridurre le occorrenze di un elemento generico.
/// Resta in ascolto di un [Bloc] generico specificato, e ad un suo evento
/// richiede la traduzione del nuovo stato in un valore numerico da visualizzare
/// tramite la funzione [stateToCount].

class AddRemove<B extends StateStreamable<S>, S> extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onRemovePressed;
  final int Function(S state) stateToCount;
  final void Function(BuildContext context, S state)? listener;
  final bool Function(S previous, S current)? buildWhen;
  final B bloc;
  final Axis direction;

  const AddRemove({
    super.key,
    required this.bloc,
    required this.onAddPressed,
    required this.onRemovePressed,
    required this.stateToCount,
    this.listener,
    this.buildWhen,
    this.direction = Axis.vertical
  });

  List<Widget> contentList(BuildContext context)
  {
    return [
      createButton(
        context: context,
        backgroundColor: Colors.white,
        borderColor: Theme.of(context).primaryColor,
        iconColor: Theme.of(context).primaryColor,
        icon: Icons.remove,
        onPressed: onRemovePressed.call,
        borderRadius: direction == Axis.horizontal?
        const BorderRadius.only(
          topLeft: Radius.circular(defaultBorderRadius),
          bottomLeft: Radius.circular(defaultBorderRadius),
        ):
        const BorderRadius.only(
          bottomRight: Radius.circular(defaultBorderRadius),
          bottomLeft: Radius.circular(defaultBorderRadius),
        )
      ),
      const Gap(10),
      BlocConsumer<B,S>(
        bloc: bloc,
        buildWhen: buildWhen,
        listener: (context, state) {
          listener?.call(context, state);
        },
        builder: (context, state) {
          int count = stateToCount(state);
          return Text("$count".padLeft(2,'0'));
        },
      ),
      const Gap(10),
      createButton(
        context: context,
        backgroundColor: Colors.white,
        borderColor: Theme.of(context).primaryColor,
        iconColor: Theme.of(context).primaryColor,
        icon: Icons.add,
        onPressed: onAddPressed.call,
        borderRadius: direction == Axis.horizontal?
        const BorderRadius.only(
          topRight: Radius.circular(defaultBorderRadius),
          bottomRight: Radius.circular(defaultBorderRadius),
        ):
        const BorderRadius.only(
          topLeft: Radius.circular(defaultBorderRadius),
          topRight: Radius.circular(defaultBorderRadius),
        )
      ),
    ];
  }

  Widget createButton({
    required BuildContext context,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onPressed,
    required BorderRadius borderRadius
  }) 
  {
    return Expanded(
      child: Material(
        color: backgroundColor,
        // borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed.call,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Icon(icon, color: iconColor,),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      // borderRadius: BorderRadius.circular(20),
      elevation: 0,
      color: Colors.white,
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        children: direction == Axis.horizontal? 
        contentList(context):
        contentList(context).reversed.toList(),
      ),
    );
  }
}
