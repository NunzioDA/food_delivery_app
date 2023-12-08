import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Presentation/Pages/home_page.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late UserBloc userBloc;

  @override
  void initState() {
    userBloc = UserBloc();
    userBloc.add(const VerifyLoggedInEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = GoogleFonts.outfitTextTheme();    

    return BlocProvider(
      create: (context) => userBloc,
      child: MaterialApp(
        title: 'Food Delivery App',
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.all(15),
            focusedBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
            labelStyle: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w100, color: Colors.grey.shade800),
            floatingLabelStyle:
                textTheme.bodySmall?.copyWith(color: Palette.primary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
              ),
            ),
          ),
          primaryColor: Palette.primary,
          primaryColorLight: Palette.primary.shade100,
          primaryColorDark: Palette.primary.shade800,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Palette.primary,
              primary: Palette.primary,
              onPrimary: Palette.onPrimaryText,
              inversePrimary: Palette.primary.shade100,
              primaryContainer: Colors.black),
          textTheme: textTheme.copyWith(
            headlineLarge: textTheme.headlineLarge!.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Palette.primary.shade800),
            titleLarge: textTheme.titleLarge!.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Palette.primary),
            titleMedium: textTheme.titleMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Palette.primary.shade800),
            titleSmall: textTheme.titleSmall!.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Palette.primary.shade800),
            bodyMedium: textTheme.bodySmall!.copyWith(
                fontSize: 15, fontWeight: FontWeight.w200, color: Colors.grey),
            headlineMedium: textTheme.bodyMedium!.copyWith(
                fontSize: 20, fontWeight: FontWeight.w100, color: Colors.grey),
          ),
          useMaterial3: false,
        ),
        home: const HomePage()
      ),
    );
  }
}
