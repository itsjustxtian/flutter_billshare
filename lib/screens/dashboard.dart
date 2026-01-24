import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF283C27),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCard(
              width: double.infinity,
              title: Text(
                'Monthly Summary',
                style: TextStyle(color: Colors.white),
              ),
              description: Text(
                'Expense summary for this month.',
                style: TextStyle(color: Colors.white),
              ),
              border: Border.all(width: 0),
              shadows: [
                BoxShadow(
                  offset: Offset.zero,
                  blurRadius: 10,
                  color: Color(0xFF000000).withValues(alpha: 0.25),
                ),
              ],
              backgroundColor: Color(0xFF3A4F39),
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 16),
                child: ShadCard(
                  width: double.infinity,
                  backgroundColor: Color(0xFF000000).withValues(alpha: 0.25),
                  border: Border.all(width: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PHP 200.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'January 22, 2026',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ShadButton.secondary(
                        backgroundColor: Color(0xFF415F40),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ShadCard(
                            width: double.infinity,
                            backgroundColor: Color(0xFF3C4E3C),
                            border: Border.all(
                              width: 0,
                              color: Colors.transparent,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      // Optional: round only the left corners
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Electricity Bill",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Dec 24, 2026",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.50),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "PHP 20,000.00",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
