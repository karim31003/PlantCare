import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gardain/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 0),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildQuickScanCard(),
                    const SizedBox(height: 32),
                    _buildOverviewSection(),
                    const SizedBox(height: 32),
                    _buildMyJungleSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? "User";
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return FadeTransition(
      opacity: _headerController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(_headerController),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $fullName",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your garden flourishes today",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.oliveGreen,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.lightLime.withOpacity(0.2),
                  backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                  child: avatarUrl == null 
                    ? const Icon(Icons.person, color: AppTheme.oliveGreen)
                    : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= QUICK SCAN CARD =================

  Widget _buildQuickScanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.95),
            AppTheme.darkLime.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightLime.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightLime.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  color: AppTheme.lightLime,
                  size: 24,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.lightLime.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  "AI-Powered",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: const Color.fromARGB(255, 250, 250, 249),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Quick Scan",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Analyze plant health with a single tap",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightLime,
                foregroundColor: AppTheme.oliveGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: Text(
                "Start Scanning",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= OVERVIEW =================

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Overview",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.oliveGreen,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildMetricCard(
                icon: Icons.local_florist_rounded,
                title: "Total Plants",
                value: "12",
                color: AppTheme.primaryGreen,
                accentColor: AppTheme.lightLime.withOpacity(0.2),
              ),
              _buildMetricCard(
                icon: Icons.water_drop_rounded,
                title: "Next Watering",
                value: "2h",
                color: AppTheme.darkLime,
                accentColor: AppTheme.darkLime.withOpacity(0.15),
              ),
              _buildMetricCard(
                icon: Icons.favorite_rounded,
                title: "Health",
                value: "95%",
                color: AppTheme.primaryGreen,
                accentColor: AppTheme.lightLime.withOpacity(0.2),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color accentColor,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.oliveGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          )
        ],
      ),
    );
  }

  // ================= MY JUNGLE =================

  Widget _buildMyJungleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Jungle",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.oliveGreen,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildPlantCard(
          name: "Monstera",
          location: "Living Room",
          status: "Healthy",
          statusColor: AppTheme.primaryGreen,
          statusBg: AppTheme.primaryGreen.withOpacity(0.15),
          imageUrl:
              "https://images.unsplash.com/photo-1501004318641-b39e6451bec6",
        ),
        _buildPlantCard(
          name: "Fiddle Leaf",
          location: "Bedroom",
          status: "Thirsty",
          statusColor: AppTheme.darkLime,
          statusBg: AppTheme.darkLime.withOpacity(0.15),
          imageUrl:
              "https://images.unsplash.com/photo-1501004318641-b39e6451bec6",
        ),
      ],
    );
  }

  Widget _buildPlantCard({
    required String name,
    required String location,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}