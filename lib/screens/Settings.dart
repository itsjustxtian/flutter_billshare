import 'package:flutter/material.dart';
import 'package:flutter_billshare/main.dart';
import 'package:flutter_billshare/screens/edit_profile.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserInfo {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? username;
  final DateTime? updatedAt;
  final String? websiteUrl;

  UserInfo({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.username,
    this.updatedAt,
    this.websiteUrl,
  });
}

Future<UserInfo?> getFullUserInfo() async {
  final authUser = supabase.auth.currentUser;
  if (authUser == null) {
    return null;
  }

  final profile = await supabase
      .from('profiles')
      .select()
      .eq('id', authUser.id)
      .single();

  return UserInfo(
    id: authUser.id,
    email: authUser.email,
    fullName: profile['full_name'],
    avatarUrl: profile['avatar_url'],
    username: profile['username'],
    updatedAt: profile['updated_at'] != null
        ? DateTime.parse(profile['updated_at'])
        : DateTime.now(),
    websiteUrl: profile['website'],
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = supabase.auth.currentUser;
  UserInfo? userData;
  bool isLoading = true;

  Future<void> _loadUser() async {
    final info = await getFullUserInfo();
    if (mounted) {
      setState(() {
        userData = info;
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadUser();

    if (!mounted) return;
    ShadSonner.of(
      context,
    ).show(const ShadToast(title: Text('User information updated!')));
  }

  Future<dynamic> bottomSheetBuilder(
    BuildContext context,
    UserInfo userProfile,
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
            Flexible(child: EditProfilePage(profile: userProfile)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ListTile(
                leading: ShadAvatar(
                  userData?.avatarUrl ??
                      'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                  placeholder: Text('CN'),
                ),
                title: Text(
                  userData?.username ?? 'Guest',
                  style: context.mainProfileTitle,
                ),
                subtitle: Text(
                  userData?.email ?? 'No email provided',
                  style: context.mainProfileSubtitle,
                ),
              ),
              ShadSeparator.horizontal(
                margin: EdgeInsets.all(8),
                color: context.lightGreen,
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: context.white,
                  size: 24,
                ),
                title: Text('Full Name', style: context.settingsTitle),
                subtitle: Text(
                  userData?.fullName ?? 'No full name provided.',
                  style: context.settingsSubtitle,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.alternate_email,
                  color: context.white,
                  size: 24,
                ),
                title: Text('Username', style: context.settingsTitle),
                subtitle: Text(
                  userData?.username ?? 'No username provided.',
                  style: context.settingsSubtitle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.email, color: context.white, size: 24),
                title: Text('Email', style: context.settingsTitle),
                subtitle: Text(
                  userData?.email ?? 'No email provided.',
                  style: context.settingsSubtitle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.today, color: context.white, size: 24),
                title: Text('Member Since', style: context.settingsTitle),
                subtitle: Text(
                  DateFormat(
                    'MMMM dd, yyyy',
                  ).format(DateTime.parse(user!.createdAt)),
                  style: context.settingsSubtitle,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShadButton.outline(
                    pressedBackgroundColor: context.lightGreen,
                    pressedForegroundColor: context.darkGreen,
                    foregroundColor: context.white,
                    leading: Icon(Icons.edit, color: context.white),
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      bottomSheetBuilder(context, userData!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
