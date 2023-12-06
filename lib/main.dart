import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/Pages/home_page.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    TextTheme textTheme = GoogleFonts.outfitTextTheme();

    return MaterialApp(
      title: 'Food Delivery App',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10)
              ),
            ),
          ),
        ),
        primaryColor: Palette.primary,
        primaryColorLight: Palette.primary.shade100,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.primary, 
          primary: Palette.primary,          
          onPrimary: Palette.onPrimaryText,
          inversePrimary: Palette.primary.shade100,
          primaryContainer: Colors.black
        ),
        textTheme: textTheme.copyWith(
          titleLarge: textTheme.titleLarge!.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Palette.primary.shade800
          ),
          titleMedium: textTheme.titleMedium!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Palette.primary.shade800
          ),
          titleSmall: textTheme.titleSmall!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Palette.primary.shade800
          ),
          bodyMedium: textTheme.bodySmall!.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w200,
            color: Colors.grey
          ),
        ),
        useMaterial3: false,
      ),
      home: const MyHomePage(),
    );
  }
}


