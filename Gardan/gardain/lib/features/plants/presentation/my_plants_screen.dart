import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  int _selectedFilterIndex = 0;

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.lightLime,
        foregroundColor: AppTheme.oliveGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: () {},
        child: const Icon(Icons.add_rounded, size: 24),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header Section
            FadeTransition(
              opacity: _headerController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
                    .animate(_headerController),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Garden",
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "12 plants in your collection",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.oliveGreen,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Filter Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _filterChip("All Plants", Icons.yard_rounded, 0),
                  _filterChip("Needs Water", Icons.water_drop_rounded, 1),
                  _filterChip("Healthy", Icons.check_circle_rounded, 2),
                  _filterChip("Needs Care", Icons.healing_rounded, 3),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  return _plantCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // 🔹 Plant Card
  // ==============================

  Widget _plantCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Image + Status
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: "https://garden.qa/cdn/shop/files/freepik__professional-studio-photograph-of-a-live-aloe-vera__98841.jpg?v=1762008505",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.oliveGreen.withOpacity(0.05),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),

                // Gradient Overlay for visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        stops: const [0, 0.2, 0.8, 1],
                      ),
                    ),
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Healthy",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppTheme.oliveGreen,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fiddle Leaf Fig",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.oliveGreen,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ficus lyrata",
                      style: GoogleFonts.outfit(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "WATERING",
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF9CA3AF),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop_rounded,
                                  color: AppTheme.primaryGreen,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "2 days",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.oliveGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==============================
  // 🔹 Filter Chip
  // ==============================

  Widget _filterChip(String text, IconData icon, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryGreen
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.white
                    : AppTheme.oliveGreen,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.white : AppTheme.oliveGreen,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // 🔹 Bottom Navigation
  // ==============================

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: Color(0xffEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(Icons.local_florist_rounded, "My Garden", true),
          _NavItem(Icons.center_focus_weak_rounded, "Diagnose", false),
          _NavItem(Icons.person_rounded, "Profile", false),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppTheme.primaryGreen : const Color(0xFF9CA3AF),
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? AppTheme.primaryGreen : const Color(0xFF9CA3AF),
          ),
        )
      ],
    );
  }
}