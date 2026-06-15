import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/bill_services.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UpdateBillPaymentPage extends StatefulWidget {
  final List<BillPayments> billPayment;

  const UpdateBillPaymentPage({super.key, required this.billPayment});

  @override
  State<UpdateBillPaymentPage> createState() => _UpdateBillPaymentPageState();
}

class _UpdateBillPaymentPageState extends State<UpdateBillPaymentPage> {
  final BillService _billService = BillService();
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Update Contributions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 1,
                  child: Text('Owed', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Paid', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          ShadSeparator.horizontal(
            margin: EdgeInsets.symmetric(vertical: 4),
            color: context.darkGreen,
          ),
          for (var payment in widget.billPayment) ...[
            _buildPaymentInputs(payment),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
          ShadButton(
            child: const Text('Save All Changes'),
            onPressed: () => _saveChanges(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInputs(BillPayments payment) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            payment.memberName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '₱${payment.amountOwed.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: ShadInput(
            initialValue: payment.amountPaid != 0.0
                ? payment.amountPaid.toString()
                : null,
            leading: Text('₱'),
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: context.addBillFormInputDecoration,
            onChanged: (value) {
              // 2. Update the object directly
              final numValue = double.tryParse(value) ?? 0.0;
              // Note: You might want to create a copy of the list to avoid side effects
              payment.amountPaid = numValue;
            },
          ),
        ),
      ],
    );
  }

  void _saveChanges() async {
    // 1. Show loading state
    setState(() => isLoading = true);

    try {
      // 2. Loop through all payments and update each one
      for (var payment in widget.billPayment) {
        // We use your existing _parseAmount to ensure we have a clean double
        final amount = double.tryParse(payment.amountPaid.toString()) ?? 0.0;

        await _billService.recordPartialPayment(payment.paymentId, amount);
      }

      // 3. Success feedback
      if (!mounted) return;

      final sonner = ShadSonner.of(context);
      final id = Random().nextInt(1000);

      ShadSonner.of(context).show(
        ShadToast(
          id: id,
          title: Text('Payments Updated'),
          description: Text('All records have been successfully saved.'),
          backgroundColor: const Color(0xFFDBF6DA),
          action: ShadButton(
            backgroundColor: const Color(0xFF24240F),
            child: const Text('Close'),
            onPressed: () => sonner.hide(id),
          ),
        ),
      );

      // Optional: Navigate back or refresh the previous screen
      Navigator.pop(context);
    } catch (e) {
      // 4. Error feedback
      if (!mounted) return;

      final sonner = ShadSonner.of(context);
      final id = Random().nextInt(1000);

      ShadSonner.of(context).show(
        ShadToast.destructive(
          id: id,
          title: const Text('Update Failed'),
          description: Text(e.toString()),
          backgroundColor: const Color(0xFFDBF6DA),
          action: ShadButton(
            backgroundColor: const Color(0xFF24240F),
            child: const Text('Close'),
            onPressed: () => sonner.hide(id),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
