import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/dashboard.dart';
import 'package:flutter_billshare/screens/bills.dart';
import 'package:flutter_billshare/screens/analytics.dart';
import 'package:flutter_billshare/screens/settings.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:flutter_billshare/widgets/main_drawer.dart';
import 'package:flutter_billshare/screens/authentication_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mptjfwgrofirqbfbhaoa.supabase.co',
    anonKey: 'sb_publishable_Vpdm4Sutt2TIrBoPcyR8cQ_CmTFg9sJ',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
    case 'Login':
      return AuthenticationPage();
    default:
      return Homepage();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'BillShare',
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // 👈 decide login vs home here
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session == null) {
          print("Not Logged in.");
          return AuthenticationPage();
        } else {
          return const MyHomePage(title: 'BillShare');
        }
      },
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
  String currentPage = "Home"; // 👈 default to Home

  void setSelectedPage(String selectedPage) {
    setState(() {
      currentPage = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.background,
        title: Text(
          currentPage,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, color: Colors.white),
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
