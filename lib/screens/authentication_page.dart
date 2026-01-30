import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool obscure = true;
  bool obscureSignUp = true;

  String currentTab = 'login';

  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Welcome back to BillShare!')),
        );
        // Navigate to your main screen here
      }
    } on AuthException catch (error) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Login Failed'),
            description: Text(error.message),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            description: Text('An unexpected error occurred.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Success!'),
            description: Text('Check your email for a confirmation link.'),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !EmailValidator.validate(email)) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Please enter a valid email address first.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(email);

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Reset link sent!'),
            description: Text('Check your inbox to reset your password.'),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: Color(0xFF2D3E1C),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ShadTabs<String>(
                  value: currentTab,
                  onChanged: (val) {
                    setState(() => currentTab = val);
                  },
                  tabBarConstraints: const BoxConstraints(maxWidth: 400),
                  contentConstraints: const BoxConstraints(maxWidth: 400),
                  tabs: [
                    ShadTab(
                      value: 'login',
                      content: ShadCard(
                        title: const Text('Sign In'),
                        description: const Text(
                          "Sign in to your existing account.",
                        ),
                        footer: ShadButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Log In'),
                        ),
                        child: Form(
                          key: _loginFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              ShadInputFormField(
                                controller: _emailController,
                                label: const Text('Email'),
                                initialValue: null,
                                placeholder: Text('juandelacruz@email.com'),
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
                              const SizedBox(height: 8),
                              ShadInputFormField(
                                controller: _passwordController,
                                label: const Text('Password'),
                                initialValue: null,
                                placeholder: Text('Password'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                                obscureText: obscure,
                                trailing: ShadButton(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    obscure
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure = !obscure);
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ShadButton.link(
                                  padding: EdgeInsets.zero,
                                  onPressed: _isLoading
                                      ? null
                                      : _handleForgotPassword,
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('Log In'),
                    ),
                    ShadTab(
                      value: 'register',
                      content: ShadCard(
                        title: const Text('Sign Up'),
                        description: const Text(
                          "Create a new account using your email address. Only active email addresses may receive a password reset link.",
                        ),
                        footer: ShadButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Register'),
                        ),

                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            children: [
                              ShadInputFormField(
                                controller: _emailController,
                                label: const Text('Email'),
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
                              const SizedBox(height: 8),
                              ShadInputFormField(
                                controller: _passwordController,
                                label: const Text('Password'),
                                obscureText: obscureSignUp,
                                trailing: ShadButton(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    obscureSignUp
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => obscureSignUp = !obscureSignUp,
                                    );
                                  },
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              ShadInputFormField(
                                controller: _confirmController,
                                label: const Text('Confirm Password'),
                                obscureText: obscureSignUp,
                                trailing: ShadButton(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    obscureSignUp
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => obscureSignUp = !obscureSignUp,
                                    );
                                  },
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
