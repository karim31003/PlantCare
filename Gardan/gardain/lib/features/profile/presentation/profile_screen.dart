import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? "User";
    final email = user?.email ?? "No email";
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.lightLime,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null 
                          ? const Icon(Icons.person, size: 50, color: AppTheme.oliveGreen)
                          : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.oliveGreen),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      
                      // Account Settings Section
                      _buildSectionHeader("Account Settings"),
                      _buildProfileOption(Icons.edit, "Edit Profile", onTap: () {}),
                      _buildProfileOption(Icons.settings, "Settings", onTap: () {}),
                      _buildProfileOption(Icons.help_outline, "Help & Support", onTap: () {}),
                      
                      const SizedBox(height: 5),
                      
                      // Notifications & Logout Section
                      _buildSectionHeader("Notifications & Logout"),
                      _buildNotificationToggle(),
                      _buildProfileOption(Icons.logout, "Logout", onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) context.go('/login');
                      }, isDestructive: true),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.oliveGreen.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeColor: AppTheme.primaryGreen,
        secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryGreen),
        title: Text(
          "Push Notifications",
          style: GoogleFonts.outfit(
            color: AppTheme.oliveGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: true,
        onChanged: (bool value) {},
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {required VoidCallback onTap, bool isDestructive = false}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : AppTheme.primaryGreen),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: isDestructive ? Colors.red : AppTheme.oliveGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}