import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String currentPage = "";

  void setSelectedPage(String selectedPage) {
    setState(() {
      currentPage = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is the Analytics page."));
  }
}
