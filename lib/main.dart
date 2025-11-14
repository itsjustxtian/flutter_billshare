import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/Homepage.dart';
import 'package:flutter_billshare/screens/Bills.dart';
import 'package:flutter_billshare/screens/Analytics.dart';
import 'package:flutter_billshare/screens/Settings.dart';
import 'package:flutter_billshare/widgets/main_drawer.dart';

void main() {
  runApp(const MyApp());
}

Widget getSelectedPage(String pageName) {
  switch (pageName) {
    case 'Home':
      return Homepage();
    case 'Bills':
      return BillsPage();
    case 'Analytics':
      return AnalyticsPage();
    case 'Settings':
      return SettingsPage();
    default:
      return Homepage();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillShare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'BillShare'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentPage = "";

  void setSelectedPage(String selectedPage) {
    setState(() {
      currentPage = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(currentPage),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
      ),
      body: getSelectedPage(currentPage),
      drawer: MainDrawer(
        onSelectPage: (pageName) {
          setSelectedPage(pageName);
        },
      ),
    );
  }
}
