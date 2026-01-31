import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/update_bill_payment.dart';
import 'package:flutter_billshare/utils/bill_services.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ViewBillPage extends StatefulWidget {
  final BillInstance bill;

  const ViewBillPage({super.key, required this.bill});

  @override
  State<ViewBillPage> createState() => _ViewBillPageState();
}

class _ViewBillPageState extends State<ViewBillPage> {
  final BillService _billService = BillService();
  List<BillPayments> memberPayments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final data = await _billService.fetchPaymentsForBill(
        widget.bill.instanceId,
      );

      setState(() {
        memberPayments = data
            .map((json) => BillPayments.fromMap(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      final sonner = ShadSonner.of(context);
      final id = Random().nextInt(1000);
      sonner.show(
        ShadToast.destructive(
          id: id,
          title: const Text('Failed to load payments.'),
          description: Text(e.toString()),
          action: ShadButton.destructive(
            child: const Text('Close'),
            onPressed: () => sonner.hide(id),
          ),
        ),
      );
    }
  }

  Future<void> _updateStatus() async {
    // 1. Determine the new status based on current status
    final String newStatus = widget.bill.status == 'Paid' ? 'Pending' : 'Paid';

    try {
      // 2. Update Supabase via your Service
      // Ensure you have this method in your BillService
      await _billService.updateBillStatus(widget.bill.instanceId, newStatus);

      setState(() {
        widget.bill.status = newStatus;
      });

      // 4. Show success feedback
      if (!mounted) return;
      ShadSonner.of(context).show(
        ShadToast(
          title: Text('Bill updated to $newStatus'),
          description: Text('The bill status has been successfully synced.'),
        ),
      );
    } catch (e) {
      // 5. Handle errors
      if (!mounted) return;
      ShadSonner.of(context).show(
        ShadToast.destructive(
          title: const Text('Update failed'),
          description: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.darkBackground,
      appBar: AppBar(
        backgroundColor: context.darkBackground,
        elevation: 1,
        iconTheme: IconThemeData(color: context.white),
        title: Text(
          'View Bill',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShadCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amount Due'),
                          Text(
                            widget.bill.amountDue.toString(),
                            style: context.viewBillTitle,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.bill.dueDate).toString(),
                          ),
                          Text(widget.bill.status),
                        ],
                      ),
                    ],
                  ),
                  ShadSeparator.horizontal(
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      widget.bill.title,
                      style: context.viewBillTitle,
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(widget.bill.description ?? 'No description'),
                  ),
                  ShadSeparator.horizontal(
                    margin: EdgeInsets.symmetric(vertical: 16),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      'Members and Contributions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  isLoading
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : memberPayments.isEmpty
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: Text("No member data found.")),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < memberPayments.length; i++) ...[
                              _buildMemberAccordion(memberPayments[i], i + 1),
                              const SizedBox(
                                height: 8,
                              ), // Gap between accordions
                            ],
                          ],
                        ),
                  SizedBox(height: 16),
                  ShadButton(
                    child: Text('Update Contributions'),
                    onPressed: () {
                      bottomSheetBuilder(context, memberPayments);
                    },
                  ),
                  SizedBox(height: 16),
                  ShadButton(
                    backgroundColor: widget.bill.status != 'Paid'
                        ? Colors.green
                        : Colors.grey,
                    leading: widget.bill.status != 'Paid'
                        ? Icon(Icons.done_all)
                        : Icon(Icons.cancel),
                    onPressed: _updateStatus,
                    child: widget.bill.status != 'Paid'
                        ? Text('Mark Bill as Paid')
                        : Text('Mark Bill as Pending'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMemberAccordion(BillPayments payment, int index) {
  final double bal = payment.amountOwed - (payment.amountPaid ?? 0.0);
  final bool isPaid = bal <= 0;

  return MoonAccordion(
    accordionSize: MoonAccordionSize.sm,
    childrenPadding: const EdgeInsets.all(12),
    leading: Text('#$index'),
    label: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(payment.memberName),
        Text(
          isPaid ? "Paid" : "Pending",
          style: TextStyle(
            color: isPaid ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Amount Owed:'),
          Text('₱${payment.amountOwed.toStringAsFixed(2)}'),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Amount Paid:'),
          Text('₱${(payment.amountPaid ?? 0.0).toStringAsFixed(2)}'),
        ],
      ),
      const ShadSeparator.horizontal(margin: EdgeInsets.symmetric(vertical: 8)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Balance Left:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '₱${bal.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bal > 0 ? Colors.redAccent : Colors.green,
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Last Transaction:',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          ),
          SizedBox(width: 8),
          Text(
            payment.paidAt != null
                ? DateFormat('MMM dd, yyyy').format(payment.paidAt!)
                : 'No payment made',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ],
      ),
    ],
  );
}

Future<dynamic> bottomSheetBuilder(
  BuildContext context,
  List<BillPayments> payments,
) {
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
          Flexible(child: UpdateBillPaymentPage(billPayment: payments)),
        ],
      ),
    ),
  );
}
