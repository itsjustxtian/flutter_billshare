import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/bill_services.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ViewBillPage extends StatefulWidget {
  final BillInstance bill;

  const ViewBillPage({super.key, required this.bill});

  @override
  State<ViewBillPage> createState() => _ViewBillPageState();
}

class _ViewBillPageState extends State<ViewBillPage> {
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
                  child: Text(widget.bill.title, style: context.viewBillTitle),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
