import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AddRemove<B extends StateStreamable<S>, S> extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onRemovePressed;
  final int Function(S state) stateToCount;
  final void Function(BuildContext context, S state)? listener;
  final B bloc;

  const AddRemove({
    super.key,
    required this.bloc,
    required this.onAddPressed,
    required this.onRemovePressed,
    required this.stateToCount,
    this.listener
  });

  Widget createButton(
      {required BuildContext context,
      required Color backgroundColor,
      required Color borderColor,
      required Color iconColor,
      required IconData icon,
      required VoidCallback onPressed,
      required BoxConstraints constraints
}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Material(
          clipBehavior: Clip.hardEdge,
          color: backgroundColor,
          child: InkWell(
            onTap: onPressed.call,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                icon,
                color: iconColor,
                size: constraints.maxWidth / 3 - 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 100,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              createButton(
                context: context,
                backgroundColor: Colors.white,
                borderColor: Theme.of(context).primaryColor,
                iconColor: Theme.of(context).primaryColor,
                icon: Icons.remove,
                onPressed: onRemovePressed.call,
                constraints:constraints
              ),
              const Gap(10),
              BlocConsumer<B,S>(
                bloc: bloc,
                listener: (context, state) {
                  listener?.call(context, state);
                },
                builder: (context, state) {
                  int count = stateToCount(state);
                  return Text("${count}x");
                },
              ),
              const Gap(10),
              createButton(
                context: context,
                backgroundColor: Theme.of(context).primaryColor,
                borderColor: Colors.transparent,
                iconColor: Colors.white,
                icon: Icons.add,
                onPressed: onAddPressed.call,
                constraints:constraints
              ),
            ],
          );
        }
      ),
    );
  }
}
