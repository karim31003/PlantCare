// lib/features/profile/presentation/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _pwCtrl    = TextEditingController();
  final TextEditingController _newPwCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePw    = true;
  bool _obscureNewPw = true;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _nameCtrl  = TextEditingController(
        text: user?.userMetadata?['full_name'] ??
              user?.userMetadata?['name'] ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _pwCtrl.dispose();   _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;

      // Update display name
      await client.auth.updateUser(UserAttributes(
        data: {'full_name': _nameCtrl.text.trim()},
      ));

      // Update password if provided
      if (_newPwCtrl.text.trim().isNotEmpty) {
        await client.auth
            .updateUser(UserAttributes(password: _newPwCtrl.text.trim()));
      }

      if (mounted) {
        _showSnack('Profile updated successfully ✓', isError: false);
        context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit()),
      backgroundColor: isError ? Colors.red : AppTheme.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        backgroundColor: AppTheme.oliveGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text('Save',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryGreen, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.lightLime.withOpacity(0.2),
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.oliveGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personal info section
            _sectionLabel('Personal Information'),
            const SizedBox(height: 10),
            _buildCard([
              _buildField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const Divider(height: 1, indent: 56),
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                enabled: false,
                keyboardType: TextInputType.emailAddress,
                helperText: 'Email cannot be changed here',
              ),
            ]),

            const SizedBox(height: 20),

            // Password section
            _sectionLabel('Change Password'),
            const SizedBox(height: 10),
            _buildCard([
              _buildField(
                controller: _newPwCtrl,
                label: 'New Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureNewPw,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPw
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF878787),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNewPw = !_obscureNewPw),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // optional
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
                helperText: 'Leave blank to keep current password',
              ),
            ]),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Save Changes',
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF565959),
          letterSpacing: 0.3));

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? helperText,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.outfit(
            fontSize: 14, color: const Color(0xFF0F1111)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
              fontSize: 13, color: const Color(0xFF878787)),
          prefixIcon:
              Icon(icon, color: AppTheme.primaryGreen, size: 20),
          suffixIcon: suffixIcon,
          helperText: helperText,
          helperStyle: GoogleFonts.outfit(
              fontSize: 11, color: const Color(0xFFAAAAAA)),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      );
}
