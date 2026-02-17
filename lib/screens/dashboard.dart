import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/add_bill.dart';
import 'package:flutter_billshare/screens/view_bill.dart';
import 'package:flutter_billshare/utils/bill_services.dart';
import 'package:flutter_billshare/utils/dashboard_services.dart';
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
  final DashboardServices _services = DashboardServices();
  List<Map<String, dynamic>> bills = [];
  double _totalMonthlyExpense = 0.0;
  double _totalRemainingExpense = 0.0;
  bool _isLoading = false;
  int selectedDot = 0;

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

  Future<void> _refreshAllData() async {
    setState(() => _isLoading = true);
    try {
      // Run both database queries at the same time
      final results = await Future.wait([
        _services.getMonthlyBillInstances(),
        _services.getTotalMonthlyExpense(),
        _services.getTotalRemainingExpense(),
      ]);

      setState(() {
        bills = (results[0] as List<Map<String, dynamic>>?) ?? [];
        _totalMonthlyExpense = (results[1] as double?) ?? 0.0;
        _totalRemainingExpense = (results[2] as double?) ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading dashboard: $e");
    }
  }

  void _handleAddBill() async {
    final result = await bottomSheetBuilder(context);

    // If result is true, the user successfully saved a bill
    if (result == true) {
      _refreshAllData();
    }
  }

  // Update your existing methods to use the new logic
  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  Future<void> _handleRefresh() async {
    await _refreshAllData();

    if (!mounted) return;

    final sonner = ShadSonner.of(context);
    final id = Random().nextInt(1000);
    sonner.show(
      ShadToast(
        id: id,
        title: Text('Dashboard updated!'),
        action: ShadButton(
          child: const Text('Close'),
          onPressed: () => sonner.hide(id),
        ),
      ),
    );
  }

  Widget _buildTotalMonthlyExpenses(BuildContext context) {
    return ShadCard(
      width: double.infinity,
      title: Text(
        'Monthly Summary',
        style: TextStyle(color: context.foreground),
      ),
      description: Text(
        'Total expenses for this month.',
        style: TextStyle(color: context.foreground),
      ),
      border: Border.all(width: 1, color: context.accentGreen),
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
              if (_isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'PHP ${_totalMonthlyExpense.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildRemainingMonthlyExpenses(BuildContext context) {
    return ShadCard(
      width: double.infinity,
      title: Text(
        'Remaining Expenses',
        style: TextStyle(color: context.foreground),
      ),
      description: Text(
        'Remaining expenses as of this month.',
        style: TextStyle(color: context.foreground),
      ),
      border: Border.all(width: 1, color: context.accentGreen),
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
              if (_isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'PHP ${_totalRemainingExpense.toStringAsFixed(2)}',
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
    );
  }

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
            child: Icon(Icons.receipt_long),
            label: 'Add New Bill',
            onTap: () {
              _handleAddBill();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: OverflowBox(
                        maxWidth: MediaQuery.of(context).size.width,
                        child: MoonCarousel(
                          gap: 32,
                          itemCount: 2,
                          itemExtent: MediaQuery.of(context).size.width - 32,
                          physics: const PageScrollPhysics(),
                          onIndexChanged: (int index) =>
                              setState(() => selectedDot = index),
                          itemBuilder:
                              (BuildContext context, int itemIndex, int _) {
                                if (itemIndex == 0) {
                                  return _buildRemainingMonthlyExpenses(
                                    context,
                                  );
                                } else {
                                  return _buildTotalMonthlyExpenses(context);
                                }
                              },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    MoonDotIndicator(
                      selectedDot: selectedDot,
                      dotCount: 2,
                      selectedColor: context.darkGreen,
                      unselectedColor: context.lightGreen,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
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
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (bills.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            "No bills for this month",
                            style: TextStyle(color: context.white),
                          ),
                        ),
                      )
                    else
                      // 4. Don't use a second ScrollView or Expanded here.
                      // Just spread the list into the main Column.
                      ...bills.map((bill) {
                        final DateTime rawDate = DateTime.parse(
                          bill['due_date'],
                        );
                        final String formattedDate = DateFormat(
                          'MMM dd, yyyy',
                        ).format(rawDate);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BillCard(
                            title: bill['title'],
                            date: formattedDate,
                            amount: bill['amount_due'].toString(),
                            tagColor: bill['tag_color'] ?? '#FFFFFF',
                            status: bill['status'],
                            billData: bill,
                            onRefresh: _refreshAllData,
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
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
  final String status;
  final Map<String, dynamic> billData;
  final VoidCallback onRefresh;

  const BillCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.tagColor,
    required this.status,
    required this.billData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          // <--- Make this async
          // 1. Await the result from the ViewBillPage
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ViewBillPage(bill: BillInstance.fromMap(billData)),
            ),
          );

          // 2. If result is true (bill was deleted or updated), trigger refresh
          if (result == true) {
            onRefresh();
          }
        },
        child: ShadCard(
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
                            Expanded(
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: context.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              date,
                              style: TextStyle(
                                color: context.foreground.withValues(
                                  alpha: 0.50,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PHP $amount",
                              style: TextStyle(
                                color: context.foreground,
                                // If status is 'paid', apply strikethrough; otherwise, none.
                                decoration: status.toLowerCase() == 'paid'
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                // You can also change the thickness or color of the line
                                decorationColor: context.foreground.withValues(
                                  alpha: 0.75,
                                ),
                                decorationThickness: 2.0,
                              ),
                            ),
                            ShadBadge(
                              backgroundColor: status == 'Paid'
                                  ? Colors.green
                                  : status == 'Pending'
                                  ? Colors.amber
                                  : status == 'Overdue'
                                  ? Colors.red
                                  : Colors.grey,
                              child: Text(status),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
