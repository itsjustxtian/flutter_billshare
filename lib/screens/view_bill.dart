import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewBillPage extends StatefulWidget {
  final Map<String, dynamic>? bill;

  const ViewBillPage({super.key, this.bill});

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
      body: Placeholder(),
    );
  }
}
