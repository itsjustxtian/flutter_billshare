import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/add_bill.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final today = DateTime.now();
  bool _isSheetOpen = false;

  Future<dynamic> bottomSheetBuilder(BuildContext context) {
    return showMoonModalBottomSheet(
      context: context,
      backgroundColor: context.lightGreen,
      enableDrag: true,
      height: MediaQuery.of(context).size.height * 0.7,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: ShapeDecoration(
                color: context.darkBackground,
                shape: MoonSquircleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ).squircleBorderRadius(context),
                ),
              ),
            ),
            const Flexible(child: AddBillPage()),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> bills = [
    {
      'title': 'Electricity Bill',
      'date': 'Dec 24, 2026',
      'amount': '20,000.00',
      'tag_color': '#34C759',
    },
    {
      'title': 'Water Bill',
      'date': 'Dec 22, 2026',
      'amount': '1,200.00',
      'tag_color': '#FF383C',
    },
    {
      'title': 'Internet Bill',
      'date': 'Dec 15, 2026',
      'amount': '2,500.00',
      'tag_color': '#FF8D28',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      floatingActionButton: SpeedDial(
        visible: !_isSheetOpen,
        icon: Icons.add,
        activeIcon: Icons.close, // The icon changes when opened
        backgroundColor: context.lightGreen,
        foregroundColor: context.darkGreen,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.receipt_long, color: Colors.white),
            label: 'Add New Bill',
            backgroundColor: const Color(0xFF3A4F39),
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() => _isSheetOpen = true); // Hide the FAB

              bottomSheetBuilder(context).then((_) {
                // When the sheet is closed (swiped down or submitted)
                setState(() => _isSheetOpen = false); // Show the FAB again
              });
            },
          ),
          // SpeedDialChild(
          //   child: const Icon(Icons.group_add, color: Colors.white),
          //   label: 'Split with Friends',
          //   backgroundColor: const Color(0xFF3A4F39),
          //   labelStyle: const TextStyle(fontSize: 18.0),
          //   onTap: () => print('Split Tapped'),
          // ),
        ],
      ),
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
                style: TextStyle(color: context.foreground),
              ),
              description: Text(
                'Expense summary for this month.',
                style: TextStyle(color: context.foreground),
              ),
              border: Border.all(width: 1, color: context.accentGreen),
              shadows: [context.regularShadow],
              backgroundColor: context.cardBackground,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 16),
                child: ShadCard(
                  width: double.infinity,
                  backgroundColor: Color(0xFF000000).withValues(alpha: 0.25),
                  border: Border.all(width: 0, color: Colors.transparent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PHP 200.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: context.foreground,
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
                        DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.foreground,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: bills
                            .map(
                              (bill) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: BillCard(
                                  title: bill['title'],
                                  date: bill['date'],
                                  amount: bill['amount'],
                                  tagColor: bill['tag_color'] ?? '#FFFFFF',
                                ),
                              ),
                            )
                            .toList(),
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

class BillCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String tagColor;

  const BillCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: double.infinity,
      backgroundColor: const Color(0xFF3C4E3C),
      border: Border.all(width: 0, color: Colors.transparent),
      padding: const EdgeInsets.all(8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The side strip
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: tagColor.toColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // The content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: context.foreground,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: context.foreground.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PHP $amount",
                      style: TextStyle(color: context.foreground),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
