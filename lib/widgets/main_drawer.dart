import 'package:flutter/material.dart';

typedef PageSelectionCallback = void Function(String pageName);

class MainDrawer extends StatelessWidget {
  final PageSelectionCallback onSelectPage;

  const MainDrawer({super.key, required this.onSelectPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text("Home"),
            leading: const Icon(Icons.home),
            onTap: () {
              onSelectPage("Home");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Bills"),
            leading: const Icon(Icons.credit_card),
            onTap: () {
              onSelectPage("Bills");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Analytics"),
            leading: const Icon(Icons.analytics),
            onTap: () {
              onSelectPage("Analytics");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Settings"),
            leading: const Icon(Icons.settings),
            onTap: () {
              onSelectPage("Settings");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
