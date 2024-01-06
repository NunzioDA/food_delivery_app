import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/Pages/login_page.dart';
import 'package:food_delivery_app/Presentation/Pages/make_order_page.dart';
import 'package:food_delivery_app/Presentation/Pages/show_orders_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/side_menu.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:food_delivery_app/cubit/connectivity_cubit.dart';
import 'package:gap/gap.dart';

/// Pagina principale dell'app che mostra un menu a scorrimento laterale
/// tramite la vista [SideMenuView]. Permettendo all'utente di navigare 
/// tra le schermate [MakeOrderPage] per creare un nuovo ordine
/// la pagina [ShowOrdersPage] per visualizzare i propri ordini
/// e [ShowOrdersPage] per visualizzare, nel caso di utenti con 
/// permessi, tutti li ordini ricevuti ed eventualmente gestirli.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserBloc userBloc;
  bool requestedUserInfo = false;
  String? userName;

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);

    super.initState();
  }

  void logOutProc() {
    DialogVisualizer.showConfirmDenyDialog(
      context,
      "Logout",
      "Sei sicuro di voler uscire?",
      confirmText: "Esci",
      denyText: "Resta",
      onConfirmPressed: () {
        userBloc.add(const LogoutEvent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(userBloc),
      child: BlocConsumer<UserBloc, UserState>(
        bloc: userBloc,
        listener: (context, state) {
          if (state is FetchedUserInfoState) {
            userName = state.userInfo.name;
          } else {
            userName = null;
            if (state is LoggedInState && !requestedUserInfo) {
              userBloc.add(const FetchUserInfoEvent());
            }
          }
          
          if(state is UserErrorState)
          {
            if(state.event is LogoutEvent)
            {
              DialogVisualizer.showAlertDialog(
                context, 
                "Errore", 
                "Si sono verificati dei problemi provando ad effettuare il logout."
                "Controlla la tua connessione e riprova."
              );
            }
          }
        },
        builder: (context, state) {
          return SideMenuView(
              rotate3D: false,
              contentBorderRadius: defaultBorderRadius,
              topBarActionWidget: TopBarUserStatus(
                loggedIn: state is LoggedInState,
                name: userName,
              ),
              groups: [
                SideMenuGroup(
                  title: "Navigazione",
                   buttons: [
                    const SideMenuButton(
                      icon: ImageIcon(
                        AssetImage('assets/icons/order.png'),
                        color: Colors.white,
                      ),
                      name: "Ordina ora",
                      content: MakeOrderPage()
                    ),
                    if (userBloc.state is LoggedInState)
                    const SideMenuButton(
                      icon: ImageIcon(
                        AssetImage('assets/icons/myorders.png'),
                        color: Colors.white,
                      ),
                      name: "I miei ordini",
                      content: ShowOrdersPage(
                        hasPermission: false,
                      )
                    ),
                    if (userBloc.state is FetchedUserInfoState && 
                    (userBloc.state as FetchedUserInfoState).userInfo.hasPermission)
                    const SideMenuButton(
                      icon: ImageIcon(
                        AssetImage('assets/icons/manage_order.png'),
                        color: Colors.white,
                      ),
                      name: "Ordini ricevuti",
                      content: ShowOrdersPage(
                        hasPermission: true,
                      )
                    ),
                ]
                ),
                if (userBloc.state is LoggedInState)
                  SideMenuGroup(title: "Account", buttons: [
                    SideMenuButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      name: "Logout",
                      onPressed: logOutProc,
                    )
                  ])
              ]);
        },
      ),
    );
  }
}

class TopBarUserStatus extends StatelessWidget {
  final bool loggedIn;
  final String? name;
  const TopBarUserStatus({super.key, required this.loggedIn, this.name});

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return Hero(
        tag: "Login",
        child: Container(
          color: Theme.of(context).colorScheme.onPrimary,
          child: TextButton(
            onPressed: () {
              if(BlocProvider.of<ConnectivityCubit>(context).state is Connected)
              {
                Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const LoginSignupPage();
                  },
                ));
              }
              else{
                DialogVisualizer.showAlertDialog(
                  context, 
                  "Non sei connesso", 
                  "Sembra che tu non sia connesso. Controlla la tua connessione e riprova."
                );
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Login"),
                Gap(5),
                Icon(
                  Icons.login,
                ),
              ],
            )
          ),
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(5),
          Text("Ciao, ${name ?? ""}"),
          const Gap(5),
        ],
      );
    }
  }
}
