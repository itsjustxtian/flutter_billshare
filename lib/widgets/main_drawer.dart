import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PageSelectionCallback = void Function(String pageName);

final List<Map<String, dynamic>> menuItems = [
  {'title': 'Home', 'icon': Icons.home},
  {'title': 'Bills', 'icon': Icons.credit_card},
  {'title': 'Analytics', 'icon': Icons.analytics},
  {'title': 'Settings', 'icon': Icons.settings},
];

class MainDrawer extends StatelessWidget {
  final PageSelectionCallback onSelectPage;

  const MainDrawer({super.key, required this.onSelectPage});

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      // 1. Trigger the Supabase sign out
      await Supabase.instance.client.auth.signOut();

      // 2. Success feedback (Optional since the UI will likely switch)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed out')),
        );
      }
    } on AuthException catch (error) {
      // 3. Handle specific Supabase Auth errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      // 4. Handle unexpected errors
      debugPrint("Sign out error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          // This centers the children vertically
          mainAxisAlignment: MainAxisAlignment.start,
          // This keeps children aligned to the start (left) horizontally
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 64),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logos/billshare_logo.png',
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'BillShare',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...menuItems.map((item) {
              return ListTile(
                leading: Icon(item['icon'], color: Colors.white, size: 24),
                title: Text(
                  item['title'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  onSelectPage(item['title']);
                  Navigator.pop(context);
                },
              );
            }),
            const Spacer(),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ShadButton.destructive(
                width: double.infinity,
                onPressed: () => _handleSignOut(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.logout), Text('Sign Out')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
