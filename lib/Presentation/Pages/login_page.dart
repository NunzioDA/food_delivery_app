import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/credential_validation.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:food_delivery_app/cubit/credential_page_cubit.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatefulWidget {

  
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  final CredentialPageCubit credentialPageCubit = CredentialPageCubit();
  late UserBloc userBloc;

  String? usernameS, passwordS;

  ValueNotifier<bool> loading = ValueNotifier(false);
  ValueNotifier<String> dynamicLoadingText = ValueNotifier("");

  bool alreadyPopped = false;

  late StreamSubscription subscription;

  late AnimationController controller;
  late CurvedAnimation cardIntroAnimation;

  void showPasswordValidationError(PasswordValidationErrors error)
  {
    String message = "";

    switch(error)
    {                              
      case PasswordValidationErrors.empty:
        message = "Inserisci la password";
        break;
      case PasswordValidationErrors.hasNotUpper:
        message = "Inserisci almeno una lettera maiuscola";
        break;
      case PasswordValidationErrors.hasNotLower:
        message = "Inserisci almeno una lettera minuscola";
        break;
      case PasswordValidationErrors.hasNotNumbers:
        message = "Inserisci almeno un numero";
        break;
      case PasswordValidationErrors.hasNotSpecialChars:
        message = "Inserisci un carattere speciale";
        break;
      case PasswordValidationErrors.length:
        message = "Deve avere una lunghezza superiore a 6 caratteri";
        break;
      case PasswordValidationErrors.good:
    }

    DialogShower.showAlertDialog(
      context, 
      "Password", 
      "$message\n\n"
      "La password deve avere: \n"
      "\t- almeno una lettera maiuscola\n"
      "\t- almeno una lettera minuscola\n"
      "\t- almeno un carattere speciale\n"
      "\t- almeno un numero\n"
      "\t- lunghezza superiore a $minPassLength caratteri\n"
    );
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 700)
    )..addListener(() {setState(() {});}); 


    cardIntroAnimation = CurvedAnimation(
      parent: Tween<double>(begin: 0, end: 1).animate(controller), 
      curve: Curves.fastOutSlowIn
    );    

    // WidgetsBinding.instance.addPostFrameCallback((_) => controller.forward());

    userBloc = BlocProvider.of<UserBloc>(context);
    subscription = userBloc.stream.listen((event) { 
      String? errorMessage;
      loading.value = false;

      switch (event) {
        case WrongUsernameOrPasswordState():
          errorMessage = "Username o Password errati.";
          break;
        case UsernameAlreadyUsedState():
          errorMessage = "Questo username è già in uso.";
          break;
        case LoggedInState():
          if(!alreadyPopped){
            alreadyPopped = true;
            Navigator.of(context).pop();
          }
          break;
        case CorrectlySignedinState():
          DialogShower.showAlertDialog(
            context, 
            "Fatto!", 
            "Registrazione completata con successo",
          ).then((value) {
            loading.value = true;
            dynamicLoadingText.value = "Sto effettuando il login";
            userBloc.add(LoginEvent(usernameS!, passwordS!));
          });
          break;
        default:
          errorMessage = "Si è verificato un errore durante "
          "${(credentialPageCubit.state is LoginMode)? 
            "il login." : 
            "la registrazione."}\n\n"
          "Se il problema persiste contattaci.";
      }

      if(errorMessage!=null)
      {
        DialogShower.showAlertDialog(
          context, 
          "Attenzione!", 
          errorMessage
        );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return FdaLoading(
      loadingNotifier: loading,
      dynamicText: dynamicLoadingText,
      child: Scaffold(
        backgroundColor: defaultTransparentScaffoldBackgrounColor(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Hero(
                tag: "Login",
                child: Material(
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  color: Theme.of(context).dialogBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: BlocBuilder<CredentialPageCubit, CredentialPageState>(
                            bloc: credentialPageCubit,
                            builder: (context, state) {
                              return Text(
                                state is LoginMode ? "Login" : "Signup",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(color: Theme.of(context).primaryColor),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .fontSize! +
                                  30
                          ),
                          child: SingleChildScrollView(
                              child: LoginSignInForm(
                                credentialPageCubit: credentialPageCubit,
                                nameValidator: (value) {
                                  if(!validateName(value))
                                  {
                                    return "Inserisci un nome tra i 3 e 20 caratteri.";
                                  }
                    
                                  return null;
                                },
                                usernameValidator: (value) {
                                  if(!validateUsername(value))
                                  {
                                    return "Solo lettere e più di 6";
                                  }
                    
                                  return null;
                                },
                                passwordValidator: (value) {
                                  PasswordValidationErrors error = validatePassword(value);
                    
                                  if(credentialPageCubit.state is SignupMode)
                                  {
                                    if(error != PasswordValidationErrors.good &&
                                    error != PasswordValidationErrors.empty)
                                    {                              
                                      showPasswordValidationError(error);
                                      return "Inserisci la password correttamente";
                                    }
                                    else if(error == PasswordValidationErrors.empty)
                                    {
                                      return "Inserisci la password";
                                    }
                                  }
                                  else if(error != PasswordValidationErrors.good){
                                    return "Password errata";
                                  }
                    
                                  return null;
                                },
                                onLoginRequest: (username, password) {
                                  loading.value = true;
                                  dynamicLoadingText.value = "Sto effettuando il login";
                                  userBloc.add(
                                    LoginEvent(username, password)
                                  );
                                },
                                onSignInRequest: (name, username, password) {
                                  loading.value = true;
                                  dynamicLoadingText.value = "Sto effettuando la registazione";
                          
                                  usernameS = username;
                                  passwordS = password;
                    
                                  userBloc.add(
                                    SignupEvent(name, username, password)
                                  );
                                },
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef OnLoginRequest = void Function(String username, String password);
typedef OnSignInRequest = void Function(
  String name,
  String username,
  String password,
);

class LoginSignInForm extends StatefulWidget {
  final CredentialPageCubit credentialPageCubit;
  final FormFieldValidator<dynamic>? nameValidator;
  final FormFieldValidator<dynamic>? usernameValidator;
  final FormFieldValidator<dynamic>? passwordValidator;
  final OnLoginRequest onLoginRequest;
  final OnSignInRequest onSignInRequest;

  const LoginSignInForm(
      {super.key,
      required this.credentialPageCubit,
      this.nameValidator,
      this.usernameValidator,
      this.passwordValidator,
      required this.onLoginRequest,
      required this.onSignInRequest});

  @override
  State<LoginSignInForm> createState() => _LoginSignInFormState();
}

class _LoginSignInFormState extends State<LoginSignInForm>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  GlobalKey<FormState> formKey = GlobalKey();

  String? name;
  String? username;
  String? password;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100))
    ..addListener(() {
      setState(() {});
    });

    widget.credentialPageCubit.stream.listen((event) { 
      if(event is LoginMode)
      {
        controller.reverse();
      }
      else if(event is SignupMode)
      {
        controller.forward();
      }
    });

    animation = Tween<double>(begin: 0, end: 1).animate(controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool errorOccurred = false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: formKey,
          child: Column(
            children: [
              SizeTransition(
                sizeFactor: animation,
                child: TextFormField(
                  validator: (value) {
                    if(widget.credentialPageCubit.state is SignupMode)
                    {
                      String? result = widget.nameValidator?.call(value);
                      errorOccurred = result != null;
                      return result;
                    }

                    return null;
                  },
                  decoration: const InputDecoration(label: Text("Nome")),
                  onChanged: (value) => name = value,
                ),
              ),
              Gap(20 * animation.value),
              TextFormField(
                validator: (value) {
                  if(!errorOccurred)
                  {
                    String? result = widget.usernameValidator?.call(value);
                    errorOccurred = result != null;
                    return result;
                  }
                  return null;
                },
                decoration: const InputDecoration(label: Text("Username")),
                onChanged: (value) => username = value,
              ),
              const Gap(20),
              TextFormField(
                validator: (value) {
                  if(!errorOccurred)
                  {
                    String? result = widget.passwordValidator?.call(value);
                    errorOccurred = result != null;
                    return result;
                  }
                  return null;
                },
                decoration: const InputDecoration(label: Text("Password")),
                onChanged: (value) => password = value,
              ),
              Gap(20 * animation.value),
              SizeTransition(
                sizeFactor: animation,
                child: TextFormField(
                  validator: (value) {
                    if(widget.credentialPageCubit.state is SignupMode
                    && password != value && !errorOccurred)
                    {
                      return "Non corrisponde alla password";
                    }
                    
                    return null;
                  },
                  decoration:
                      const InputDecoration(label: Text("Conferma password")),
                ),
              ),
            ],
          )
        ),
        const Gap(20),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            child: BlocBuilder<CredentialPageCubit, CredentialPageState>(
              bloc: widget.credentialPageCubit,
              builder: (context, state) {
                return Text(state is LoginMode? "Accedi" : "Registrati");
              },
            ),
            onPressed: () {
              errorOccurred = false;
              if(formKey.currentState?.validate() ?? false){
                if(widget.credentialPageCubit.state is LoginMode)
                {
                  widget.onLoginRequest.call(username!, password!);
                }
                else {
                  widget.onSignInRequest.call(name!, username!, password!);
                }
              }
            },
          ),
        ),
        const Gap(20),
        const LoginSigninDivider(),
        const Gap(20),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              widget.credentialPageCubit.switchMode();
            }, 
            child: BlocBuilder<CredentialPageCubit, CredentialPageState>(
              bloc: widget.credentialPageCubit,
              builder: (context, state) {
                return Text(state is LoginMode? "Registrati" : "Accedi");
              },
            )
          ),
        )
      ],
    );
  }
}

class LoginSigninDivider extends StatelessWidget {
  const LoginSigninDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Divider(
              height: 2,
              thickness: 0.5,
              color: Colors.grey //Theme.of(context).primaryColor,
              ),
        ),
        Gap(20),
        Text("oppure"),
        Gap(20),
        Expanded(
          child: Divider(
              height: 2,
              thickness: 0.5,
              color: Colors.grey //Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }
}
