import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/edit_bill.dart';
import 'package:flutter_billshare/screens/update_bill_payment.dart';
import 'package:flutter_billshare/utils/bill_services.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  late BillInstance localBill;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    localBill = widget.bill;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final paymentsData = await _billService.fetchPaymentsForBill(
        localBill.instanceId,
      );
      final updatedBill = await _billService.fetchBillById(
        localBill.instanceId,
      );

      setState(() {
        memberPayments = paymentsData
            .map((json) => BillPayments.fromMap(json))
            .toList();

        if (updatedBill != null) {
          localBill = updatedBill;
        }

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
    String newStatus;

    if (localBill.status != 'Paid') {
      newStatus = 'Paid';
    } else {
      final bool isPastDue = DateTime.now().isAfter(localBill.dueDate);
      newStatus = isPastDue ? 'Overdue' : 'Pending';
    }

    try {
      await _billService.updateBillStatus(localBill.instanceId, newStatus);

      setState(() {
        localBill.status = newStatus;
      });

      if (!mounted) return;

      ShadSonner.of(context).show(
        ShadToast(
          title: Text('Bill marked as $newStatus'),
          description: const Text(
            'The bill status has been successfully synced.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ShadSonner.of(context).show(
        ShadToast.destructive(
          title: const Text('Update failed'),
          description: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    // 1. Show Shadcn UI Confirmation Dialog
    final confirmed = await showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        padding: EdgeInsets.symmetric(horizontal: 8),
        radius: BorderRadius.circular(8),
        title: Text('Are you absolutely sure?'),
        description: const Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Text(
            'This action cannot be undone. This will permanently delete this bill.',
          ),
        ),
        actions: [
          ShadButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => isLoading = true);
        await _billService.deleteBillInstance(localBill.instanceId);

        if (!mounted) return;

        final sonner = ShadSonner.of(context);
        final id = Random().nextInt(1000);
        sonner.show(
          ShadToast(
            id: id,
            title: const Text('Bill successfully deleted.'),
            action: ShadButton(
              child: const Text('Close'),
              onPressed: () => sonner.hide(id),
            ),
          ),
        );

        // 2. Pop the View Page and tell the Home Screen to refresh
        Navigator.pop(context, true);
      } catch (e) {
        setState(() => isLoading = false);
        if (!mounted) return;

        final sonner = ShadSonner.of(context);
        final id = Random().nextInt(1000);
        sonner.show(
          ShadToast.destructive(
            id: id,
            title: const Text('Failed to delete bill.'),
            // description: Text(e.toString()),
            action: ShadButton.destructive(
              child: const Text('Close'),
              onPressed: () => sonner.hide(id),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.darkBackground,
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: context.darkGreen,
        overlayOpacity: 0.5,
        backgroundColor: context.darkGreen,
        children: [
          SpeedDialChild(
            child: Icon(Icons.group),
            label: 'Update Contributions',
            backgroundColor: context.white,
            onTap: () {
              bottomSheetBuilder(context, memberPayments);
            },
          ),
          SpeedDialChild(
            child: localBill.status != 'Paid'
                ? Icon(Icons.done_all)
                : Icon(Icons.cancel),
            label: localBill.status != 'Paid'
                ? 'Mark Bill as Paid'
                : 'Mark Bill as Pending',
            backgroundColor: localBill.status != 'Paid'
                ? Colors.green
                : Colors.grey,
            foregroundColor: context.white,
            onTap: _updateStatus,
          ),
          SpeedDialChild(
            child: Icon(Icons.edit),
            label: 'Edit Bill',
            backgroundColor: Colors.amber,
            onTap: () async {
              final bool? didEdit = await editBillBottomSheetBuilder(
                context,
                localBill,
              );

              if (didEdit == true) {
                _loadPayments();
              }
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: 'Delete Bill',
            backgroundColor: Colors.red,
            onTap: _handleDelete,
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: context.darkBackground,
        elevation: 1,
        iconTheme: IconThemeData(color: context.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'View Bill',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.white,
              ),
            ),
          ],
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
                            localBill.amountDue.toString(),
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
                            ).format(localBill.dueDate).toString(),
                          ),
                          ShadBadge(
                            backgroundColor: localBill.status == 'Paid'
                                ? Colors.green
                                : localBill.status == 'Pending'
                                ? Colors.amber
                                : localBill.status == 'Overdue'
                                ? Colors.red
                                : Colors.grey,
                            child: Text(localBill.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ShadSeparator.horizontal(
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(localBill.title, style: context.viewBillTitle),
                  ),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(localBill.description ?? 'No description'),
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
                              const SizedBox(height: 8),
                            ],
                          ],
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

Future<bool?> editBillBottomSheetBuilder(
  BuildContext context,
  BillInstance billInstance,
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
          Flexible(child: EditBillPage(bill: billInstance)),
        ],
      ),
    ),
  );
}
