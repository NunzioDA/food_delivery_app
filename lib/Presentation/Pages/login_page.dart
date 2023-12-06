import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatelessWidget
{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withAlpha(110),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                color: Theme.of(context).dialogBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).primaryColor
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [                      
                          const Gap(20),
                          Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    label: Text("Username")
                                  ),
                                ),
                                const Gap(20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    label: Text("Password")
                                  ),
                                )
                              ],
                            )
                          ),
                          const Gap(20),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              child: const Text("Login"),
                              onPressed: (){
                    
                              },
                            ),
                          ),
                          const Gap(20),
                          const LoginSigninDivider(),
                          const Gap(20),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: (){}, 
                              child: Text("Registrati")
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ),
      ),
    );
  }

}

class LoginSigninDivider extends StatelessWidget
{
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
            color: Colors.grey//Theme.of(context).primaryColor,
          ),
        ),
        Gap(20),
        Text("oppure"),
        Gap(20),
        Expanded(
          child: Divider(
            height: 2, 
            thickness: 0.5, 
            color: Colors.grey//Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

}