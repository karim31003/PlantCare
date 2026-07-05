import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) context.go('/home');
      } on AuthException catch (e) {
        if (mounted) {
          String message = e.message;
          if (message.contains('Invalid login credentials')) {
            message = 'Invalid email or password. Please try again or register.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleSocialLogin(Future<void> Function() loginMethod, String providerName) async {
    try {
      await loginMethod();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$providerName Login failed: $e')),
        );
      }
    }
  }

  Future<void> _googleLogin() => _handleSocialLogin(
    () => context.read<AuthProvider>().loginWithGoogle(), 
    'Google'
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 Icon(Icons.spa, size: 80, color: AppTheme.primaryGreen), // Placeholder Logo
                 const SizedBox(height: 20),
                 Text(
                  "Welcome Back to\nMy Gardener",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.oliveGreen,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, 
                    child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: context.watch<AuthProvider>().isLoading ? null : _login,
                  child: context.watch<AuthProvider>().isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Login", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("OR")),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Login with Google"),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.oliveGreen),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text("Register", style: TextStyle(color: AppTheme.primaryGreen)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
