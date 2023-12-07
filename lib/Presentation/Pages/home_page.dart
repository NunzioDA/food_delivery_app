import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/Pages/login_page.dart';
import 'package:food_delivery_app/Presentation/Pages/order_page.dart';
import 'package:food_delivery_app/Presentation/Utilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/Utilities/side_menu.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';

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

  void logOutProc()
  {
    DialogShower.showConfirmDenyDialog(
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
    return BlocConsumer<UserBloc, UserState>(
      bloc: userBloc,
      listener: (context, state) {
        if(state is FetchedUserInfoState)
        {
          userName = state.userInfo.name;
        }
        else {
          userName = null;
          if(state is LoggedInState && !requestedUserInfo)
          {
            userBloc.add(const FetchUserInfoEvent());
          }          
        }
      },
      builder: (context, state) {     
        return SideMenuView(
            rotate3D: false,
            topBarActionWidget: TopBarUserStatus(
              loggedIn: state is LoggedInState,
              name: userName,
            ),
            groups: [
              SideMenuGroup(title: "Navigazione", buttons: [
                SideMenuButton(
                    icon: Icon(Icons.home),
                    name: "Home",
                    content: const OrderPage()),
                SideMenuButton(
                    icon: Icon(Icons.more),
                    name: "More",
                    onPressed: () {
                      print("More");
                    })
              ]),
              if (userBloc.state is LoggedInState)
                SideMenuGroup(title: "Account", buttons: [
                  SideMenuButton(
                    icon: const Icon(Icons.logout),
                    name: "Logout",
                    onPressed: logOutProc,
                  )
                ])
            ]);
      },
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
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return const LoginPage();
            },
          ));
        },
        child: const Text("Accedi"),
      );
    } else {
      return Text("Ciao, ${name ?? ""}");
    }
  }
}
