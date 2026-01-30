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
  ShadDecoration get editEmailAndPasswordFormInputDecoration => ShadDecoration(
    color: white,
    border: ShadBorder(padding: EdgeInsets.all(0), offset: 0),
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
  TextStyle get mainProfileTitle => GoogleFonts.poppins(
    color: white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  TextStyle get mainProfileSubtitle => TextStyle(color: white, fontSize: 16);
  TextStyle get mainProfileEmptySubtitle =>
      TextStyle(color: white, fontSize: 16, fontStyle: FontStyle.italic);
  TextStyle get settingsTitle => GoogleFonts.poppins(color: white);
  TextStyle get settingsSubtitle =>
      TextStyle(color: white.withValues(alpha: 0.60));
  TextStyle get viewBillTitle => GoogleFonts.poppins(
    color: darkGreen,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  TextStyle get viewBillDescription =>
      TextStyle(color: white.withValues(alpha: 0.75));
  TextStyle get viewBillDescriptionEmpty => TextStyle(
    color: white.withValues(alpha: 0.5),
    fontStyle: FontStyle.italic,
  );
}

class InvertedBottomCornerClipper extends CustomClipper<Path> {
  final double invertedRadius;
  final double outwardRadius;

  InvertedBottomCornerClipper({
    this.invertedRadius = 20.0,
    this.outwardRadius = 0.0, // Default to 0 (sharp)
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start: Top Left (Outward)
    path.moveTo(0, outwardRadius);
    path.arcToPoint(
      Offset(outwardRadius, 0),
      radius: Radius.circular(outwardRadius),
      clockwise: true, // Normal rounding
    );

    // Top Right (Outward)
    path.lineTo(size.width - outwardRadius, 0);
    path.arcToPoint(
      Offset(size.width, outwardRadius),
      radius: Radius.circular(outwardRadius),
      clockwise: true,
    );

    // Bottom Right (Inverted)
    path.lineTo(size.width, size.height - invertedRadius);
    path.arcToPoint(
      Offset(size.width - invertedRadius, size.height),
      radius: Radius.circular(invertedRadius),
      clockwise: false, // Inward scooping
    );

    // Bottom Left (Inverted)
    path.lineTo(invertedRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - invertedRadius),
      radius: Radius.circular(invertedRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class InvertedTopCornerClipper extends CustomClipper<Path> {
  final double invertedRadius;
  final double outwardRadius;

  InvertedTopCornerClipper({
    this.invertedRadius = 20.0,
    this.outwardRadius = 0.0,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Top Left (Inverted)
    path.moveTo(0, invertedRadius);
    path.arcToPoint(
      Offset(invertedRadius, 0),
      radius: Radius.circular(invertedRadius),
      clockwise: false, // Inward scooping
    );

    // Top Right (Inverted)
    path.lineTo(size.width - invertedRadius, 0);
    path.arcToPoint(
      Offset(size.width, invertedRadius),
      radius: Radius.circular(invertedRadius),
      clockwise: false,
    );

    // Bottom Right (Outward)
    path.lineTo(size.width, size.height - outwardRadius);
    path.arcToPoint(
      Offset(size.width - outwardRadius, size.height),
      radius: Radius.circular(outwardRadius),
      clockwise: true, // Normal rounding
    );

    // Bottom Left (Outward)
    path.lineTo(outwardRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - outwardRadius),
      radius: Radius.circular(outwardRadius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
