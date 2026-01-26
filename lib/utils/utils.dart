import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension HexColor on String {
  Color toColor() {
    final hexCode = replaceFirst('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

extension BrandColors on BuildContext {
  Color get background => const Color(0xFF415F40);
  Color get darkBackground => const Color(0xFF283C27);
  Color get lightBackground => const Color(0xFF3C4E3C);
  Color get foreground => const Color(0xFFFFFFFF);
  Color get white => const Color(0xFFEEF1ED);
  Color get inputBackground => const Color(0xFF98D695);
  Color get appBar => const Color(0xFF283C27);
  Color get accentGreen => const Color(0xFF415F40);
  Color get lightGreen => const Color(0xFFDBF6DA);
  Color get darkGreen => const Color(0xFF24240F);
  Color get borderLightGreen => const Color(0xFFDBF6DA);
  Color get cardBackground => const Color(0xFF3A4F39);
  BoxShadow get regularShadow => BoxShadow(
    offset: Offset.zero,
    blurRadius: 10,
    color: Color(0xFF000000).withValues(alpha: 0.25),
  );
  ShadDecoration get addBillFormInputDecoration => ShadDecoration(
    color: white,
    secondaryBorder: ShadBorder.all(
      width: 1,
      radius: BorderRadius.all(Radius.circular(4)),
      color: accentGreen,
    ),
    secondaryFocusedBorder: ShadBorder.all(
      color: accentGreen,
      radius: BorderRadius.all(Radius.circular(4)),
    ),
    labelStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      color: darkGreen,
    ),
  );
}
