// lib/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../presentation/providers/orders_provider.dart';
import '../../../presentation/providers/scans_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrdersProvider>().fetchOrders();
        context.read<ScansProvider>().fetchScans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        'User';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: 1.0,
        child: CustomScrollView(
          slivers: [
            // ── Modern Profile Header with Dynamic Safe Top Space ──
            SliverSafeArea(
              top: true,
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: _buildPremiumHeader(
                  context,
                  fullName: fullName,
                  avatarUrl: avatarUrl,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Modern Stats Cards ──
            SliverToBoxAdapter(
              child: _buildModernStatsRow(context),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Menu Sections ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Your Account',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModernSection(
                    items: [
                      _TileData(
                        icon: Icons.receipt_long_rounded,
                        label: 'Your Orders',
                        subtitle: 'Track, return or buy again',
                        badge: null,
                        color: const Color(0xFF81C784),
                        onTap: () {
                          context.read<OrdersProvider>().fetchOrders();
                          context.push('/profile/orders');
                        },
                      ),
                      _TileData(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        subtitle: 'Change name, email & password',
                        badge: null,
                        color: const Color(0xFF64B5F6),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      _TileData(
                        icon: Icons.location_on_outlined,
                        label: 'Addresses',
                        subtitle: 'Manage delivery addresses',
                        badge: null,
                        color: const Color(0xFFFFAB91),
                        onTap: () => context.push('/profile/addresses'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // App Settings Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'App Settings',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModernSection(
                    items: [
                      _TileData(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        subtitle: 'Notifications, language & theme',
                        badge: null,
                        color: const Color(0xFF90A4AE),
                        onTap: () => context.push('/profile/settings'),
                      ),
                      _TileData(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        subtitle: 'FAQs, chat with us',
                        badge: null,
                        color: const Color(0xFFCE93D8),
                        onTap: () => context.push('/profile/help'),
                      ),
                      _TileData(
                        icon: Icons.info_outline_rounded,
                        label: 'About Gardan',
                        subtitle: 'Version 1.0.0',
                        badge: null,
                        color: const Color(0xFFA8B5A0),
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Account',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModernSection(
                    items: [
                      _TileData(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        subtitle: null,
                        badge: null,
                        color: Colors.red,
                        onTap: () => _confirmSignOut(context),
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Premium Profile Header
  // ─────────────────────────────────────────────────────────────

  Widget _buildPremiumHeader(
    BuildContext context, {
    required String fullName,
    required String? avatarUrl,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6CA651),
            Color(0xFF839705),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Simplified Modern Avatar
            Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Clean User Info
            Expanded(
              child: Text(
                'Hello, $fullName 👋',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Modern Statistics Cards
  // ─────────────────────────────────────────────────────────────

  Widget _buildModernStatsRow(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final scansProvider = context.watch<ScansProvider>();
    final orderCount = ordersProvider.orders.length;
    final scanCount = scansProvider.scans.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildModernStat(
            context: context,
            icon: Icons.receipt_long_rounded,
            value: orderCount.toString(),
            label: 'Orders',
            color: const Color(0xFF81C784),
            onTap: () {
              context.read<OrdersProvider>().fetchOrders();
              context.push('/profile/orders');
            },
          ),
          const SizedBox(width: 12),
          _buildModernStat(
            context: context,
            icon: Icons.local_florist_rounded,
            value: '0',
            label: 'Plants',
            color: const Color(0xFF64B5F6),
            onTap: () => context.go('/plants'),
          ),
          const SizedBox(width: 12),
          _buildModernStat(
            context: context,
            icon: Icons.document_scanner_rounded,
            value: scanCount.toString(),
            label: 'Scans',
            color: const Color(0xFFCE93D8),
            onTap: () => context.go('/scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStat({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Modern Menu Sections
  // ─────────────────────────────────────────────────────────────
  
  Widget _buildModernSection({
    required List<_TileData> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: items.map((tile) => _buildModernTile(tile)).toList(),
        ),
      ),
    );
  }

  Widget _buildModernTile(_TileData tile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tile.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tile.isDestructive
                      ? Colors.red.withOpacity(0.08)
                      : tile.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  tile.icon,
                  color: tile.isDestructive ? Colors.red : tile.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tile.isDestructive
                            ? Colors.red
                            : const Color(0xFF1C1C1E),
                      ),
                    ),
                    if (tile.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tile.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Chevron
              if (!tile.isDestructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa,
                  color: Color(0xFF5C8D4E),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gardan-zaki',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your smart gardening companion.\nGrow better, live greener. 🌿',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF5C8D4E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────

class _TileData {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _TileData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });
}