import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/settings.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditEmailAndPasswordPage extends StatefulWidget {
  final UserInfo profile;

  const EditEmailAndPasswordPage({super.key, required this.profile});

  @override
  State<EditEmailAndPasswordPage> createState() =>
      _EditEmailAndPasswordPageState();
}

class _EditEmailAndPasswordPageState extends State<EditEmailAndPasswordPage> {
  final _formAuthKey = GlobalKey<ShadFormState>();
  bool obscureSignUp = true;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _handleAuthChanges() async {
    if (!(_formAuthKey.currentState?.saveAndValidate() ?? false)) return;

    final values = _formAuthKey.currentState!.value;
    final String currentPassword = values['current_password'];
    final String newPassword = values['new_password'];
    final String newEmail = values['email'];

    setState(() => isLoading = true);

    try {
      // 1. CALL RE-AUTHENTICATE
      // This specifically tells Supabase: "The current user is trying to do
      // something sensitive, here is their password to prove it's them."
      await _supabase.auth.signInWithPassword(
        email: widget.profile.email,
        password: currentPassword,
      );

      // Note: If your Supabase version requires the password in reauthenticate:
      // await _supabase.auth.signInWithPassword(email: widget.profile.email, password: currentPassword);

      // 2. PROCEED WITH UPDATES
      final UserAttributes attributes = UserAttributes(
        email: newEmail != widget.profile.email ? newEmail : null,
        password: newPassword.isNotEmpty ? newPassword : null,
      );

      if (attributes.email != null || attributes.password != null) {
        await _supabase.auth.updateUser(attributes);
      }

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text('Authentication verified and updated!'),
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Verification Failed'),
            description: Text(e.message),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
        child: ShadForm(
          key: _formAuthKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Email',
                style: GoogleFonts.poppins(
                  color: context.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your new email you would like to use or leave it empty if you want to use the same password. Make sure it is not already being used.',
                style: GoogleFonts.poppins(
                  color: context.darkGreen.withValues(alpha: 0.60),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ShadInputFormField(
                id: 'email',
                initialValue: widget.profile.email,
                enabled: isLoading == true ? false : true,
                label: Text('Email'),
                placeholder: const Text('ex. "juandelacruz@gmail.com"'),
                decoration: context.editEmailAndPasswordFormInputDecoration,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              ShadSeparator.horizontal(
                color: context.darkGreen.withValues(alpha: 0.5),
              ),
              Text(
                'Change Password',
                style: GoogleFonts.poppins(
                  color: context.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your new password you would like to use. Make sure it passes our password criteria.',
                style: GoogleFonts.poppins(
                  color: context.darkGreen.withValues(alpha: 0.60),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ShadInputFormField(
                id: 'new_password',
                controller: _passwordController,
                label: const Text('New Password'),
                obscureText: obscureSignUp,
                decoration: context.editEmailAndPasswordFormInputDecoration,
                trailing: ShadButton(
                  backgroundColor: Colors.transparent,
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    obscureSignUp ? Icons.visibility_off : Icons.visibility,
                    color: context.darkGreen,
                  ),
                  onPressed: () {
                    setState(() => obscureSignUp = !obscureSignUp);
                  },
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) {
                  if (value.length < 8 && value.isNotEmpty) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ShadInputFormField(
                id: 'confirm_new_password',
                controller: _confirmController,
                label: const Text('Confirm New Password'),
                obscureText: obscureSignUp,
                decoration: context.editEmailAndPasswordFormInputDecoration,
                trailing: ShadButton(
                  backgroundColor: Colors.transparent,
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    obscureSignUp ? Icons.visibility_off : Icons.visibility,
                    color: context.darkGreen,
                  ),
                  onPressed: () {
                    setState(() => obscureSignUp = !obscureSignUp);
                  },
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) {
                  if (value.isEmpty && _passwordController.text.isNotEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              ShadSeparator.horizontal(
                color: context.darkGreen.withValues(alpha: 0.5),
              ),
              Text(
                'Enter Current Password',
                style: GoogleFonts.poppins(
                  color: context.darkGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your current password to save changes.',
                style: GoogleFonts.poppins(
                  color: context.darkGreen.withValues(alpha: 0.60),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ShadInputFormField(
                id: 'current_password',
                label: const Text('Current Password'),
                obscureText: obscureSignUp,
                decoration: context.editEmailAndPasswordFormInputDecoration,
                trailing: ShadButton(
                  backgroundColor: Colors.transparent,
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    obscureSignUp ? Icons.visibility_off : Icons.visibility,
                    color: context.darkGreen,
                  ),
                  onPressed: () {
                    setState(() => obscureSignUp = !obscureSignUp);
                  },
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Password is required to save changes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShadButton(
                    backgroundColor: context.darkGreen,

                    leading: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.receipt_long, size: 18),
                    onPressed: isLoading ? null : _handleAuthChanges,
                    child: const Text('Save Changes'),
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
