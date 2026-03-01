import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for input formatters
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordRecoveryPage extends StatefulWidget {
  final String email;
  const PasswordRecoveryPage({super.key, required this.email});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _otpController =
      TextEditingController(); // Controller for the OTP field

  bool _isLoading = false;
  bool _otpSent = false;
  bool _obscure = true;
  Timer? _timer;
  int _resendCountdown = 0;

  final supabase = Supabase.instance.client;

  Future<void> _sendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(widget.email);
      setState(() => _otpSent = true);
      _startCooldown();

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text('8-digit code sent to your email!'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final otp = _otpController.text.trim();

    if (otp.length < 8) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Please enter the 8-digit code'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Verify the OTP
      await supabase.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.recovery,
      );

      // 2. Update Password
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Success!'),
            description: Text('Your password has been updated.'),
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ShadCard(
            title: const Text('Reset Password'),
            description: Text('Instructions sent to ${widget.email}'),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  if (!_otpSent) ...[
                    const Text('Click below to receive an 8-digit reset code.'),
                    const SizedBox(height: 16),
                    ShadButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      child: _isLoading
                          ? const _LoadingSpinner()
                          : const Text('Send Reset Code'),
                    ),
                  ] else ...[
                    // New OTP Input Field
                    ShadInputFormField(
                      controller: _otpController,
                      label: const Text('Reset Code'),
                      placeholder: const Text('Enter 8-digit code'),
                      keyboardType: TextInputType.number,
                      // Forces number pad and limits characters
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(LucideIcons.key, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      controller: _passwordController,
                      label: const Text('New Password'),
                      obscureText: _obscure,
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(LucideIcons.lock, size: 16),
                      ),
                      trailing: ShadButton(
                        width: 24,
                        height: 24,
                        padding: EdgeInsets.zero,
                        child: Icon(
                          _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) =>
                          v.length < 8 ? 'Min 8 characters' : null,
                    ),
                    const SizedBox(height: 24),
                    ShadButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      child: _isLoading
                          ? const _LoadingSpinner()
                          : const Text('Update Password'),
                    ),
                    ShadButton.link(
                      onPressed: (_isLoading || _resendCountdown > 0)
                          ? null
                          : _sendOtp,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Resend code in ${_resendCountdown}s'
                            : 'Resend code',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Simple helper widget to keep the code clean
class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
