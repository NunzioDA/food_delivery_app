import 'package:flutter/material.dart';

Color defaultTransparentScaffoldBackgrounColor(BuildContext context)
{
  return Theme.of(context).primaryColor.withAlpha(110);
}

class UIUtilities{
  static bool isHorizontal(BuildContext context)
  {
    Size size = MediaQuery.of(context).size;
    return size.width > size.height;
  } 
}

const double defaultBorderRadius = 20;

// Developed by Nunzio D'Amore
class _ColorWithDarkness extends Color
{

  const _ColorWithDarkness(int color, double darkness)
  // For each base color (c) it builds two linear equations:
  // One for values of darkness below 0.5, building a straight line
  // moving between the point (0, 0xFF - c) [That maximizes the color gain when
  // darkness is 0 leading to white] and (0.5, 0) [That minimize the color change
  // leading to the base color].
  // The other linear equation moves between (0.5, 0) [whitch intersect the previous
  // equation] and (1, - c) [That maximizes the color loss whe darkness is 
  // 1 leading to black].
  :super(
    (color & 0xff000000)
    | (((color >> 16) & 0xff) + (
        darkness < 0.5? ((0xFF - ((color >> 16) & 0xff))/(-0.5))
          *darkness + (0xFF - ((color >> 16) & 0xff)) 
        :(((color >> 16) & 0xff)/-0.5)*darkness + ((color >> 16) & 0xff))~/1)<<16
    | (((color >> 8) & 0xff) + (
        darkness < 0.5? ((0xFF - ((color >> 8) & 0xff))/(-0.5))
          *darkness + (0xFF - ((color >> 8) & 0xff)) 
        :(((color >> 8) & 0xff)/-0.5)*darkness + ((color >> 8) & 0xff))~/1)<<8
    | (((color >> 0) & 0xff) + (
        darkness < 0.5? ((0xFF - ((color >> 0) & 0xff))/(-0.5))
          *darkness + (0xFF - ((color >> 0) & 0xff)) 
        :(((color >> 0) & 0xff)/-0.5)*darkness + ((color >> 0) & 0xff))~/1)<<0
  );
}

class Palette {
  static const MaterialColor primary = MaterialColor(
    _primaryBaseColor, //
    <int, Color>{
      50: _ColorWithDarkness(_primaryBaseColor, 0.1),
      100:_ColorWithDarkness(_primaryBaseColor, 0.2), 
      200:_ColorWithDarkness(_primaryBaseColor, 0.3), 
      300: _ColorWithDarkness(_primaryBaseColor, 0.35),
      400: _ColorWithDarkness(_primaryBaseColor, 0.4),
      500: _ColorWithDarkness(_primaryBaseColor, 0.5),
      600: _ColorWithDarkness(_primaryBaseColor, 0.6),
      700: _ColorWithDarkness(_primaryBaseColor, 0.7),
      800: _ColorWithDarkness(_primaryBaseColor, 0.8),
      900: _ColorWithDarkness(_primaryBaseColor, 0.9),
    },
  );

  static const int _primaryBaseColor = 0xff695cb6;

  static const MaterialColor secondary = Colors.amber;

  static Color onPrimaryText = Colors.white; 

}