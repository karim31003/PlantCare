import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  bool _isAnalyzing = false;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isAnalyzing = true;
      });

      _fadeController.forward();

      // Simulate AI Analysis
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isAnalyzing = false;
      });

      _showResultSheet();
    }
  }

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultSheet(),
    );
  }

  Widget _buildResultSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: true,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            // Drag indicator
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.oliveGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  // Header
                  _buildResultHeader(),
                  const SizedBox(height: 32),

                  // Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlantInfoCard(
                          label: "Common Name",
                          value: "Monstera",
                          icon: Icons.eco_rounded,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPlantInfoCard(
                          label: "Confidence",
                          value: "98.4%",
                          icon: Icons.auto_awesome_rounded,
                          color: AppTheme.lightLime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description
                  Text(
                    "About this plant",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Monstera Deliciosa, the Swiss cheese plant, is a species of flowering plant native to tropical forests of Mexico and Panama. Its iconic holes make it a favorite for home decor.",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.oliveGreen.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Care Guidelines
                  Text(
                    "Care Guidelines",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCareTipModern(
                    icon: Icons.water_drop_rounded,
                    title: "Watering",
                    description: "Every 7-10 days",
                    color: Colors.blue[400]!,
                  ),
                  const SizedBox(height: 12),
                  _buildCareTipModern(
                    icon: Icons.wb_sunny_rounded,
                    title: "Lighting",
                    description: "Bright indirect light",
                    color: Colors.orange[400]!,
                  ),
                  const SizedBox(height: 12),
                  _buildCareTipModern(
                    icon: Icons.thermostat_rounded,
                    title: "Temperature",
                    description: "18°C - 30°C",
                    color: Colors.red[400]!,
                  ),
                  const SizedBox(height: 48),

                  // Actions
                  _buildPremiumMainButton(
                    label: "Add to My Garden",
                    icon: Icons.add_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Not my plant? Try again",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.oliveGreen.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.oliveGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.oliveGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTipModern({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.oliveGreen,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.oliveGreen.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.oliveGreen.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMainButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.oliveGreen],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _image == null
                  ? _buildEmptyState()
                  : _buildImagePreview(),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Plant Identity",
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.oliveGreen,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Background decorative circles
                ...List.generate(2, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * (0.2 + (index * 0.1))),
                        child: Container(
                          width: 140 + (index * 40).toDouble(),
                          height: 140 + (index * 40).toDouble(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.1 - (index * 0.03)),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                // Main Icon Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.2),
                        AppTheme.lightLime.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_center_focus_rounded,
                    size: 40,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              "Ready to scan?",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.oliveGreen,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Snap a photo of your plant's leaves to identify it and check for any health issues.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.oliveGreen.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image Container
          Hero(
            tag: 'scan_image',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Scanning Line Animation Overlay
          if (_isAnalyzing) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Moving Line
                      Positioned(
                        top: _scanLineController.value * MediaQuery.of(context).size.height * 0.5,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.lightLime,
                                AppTheme.lightLime,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lightLime.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Gradient Glow over the line
                      Positioned(
                        top: (_scanLineController.value * MediaQuery.of(context).size.height * 0.5) - 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.lightLime.withOpacity(0.0),
                                AppTheme.lightLime.withOpacity(0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Analyzing text overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Analyzing Detail...",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          if (_image != null)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_image != null) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _image = null;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Clear Photo",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.oliveGreen.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: _buildActionBtnModern(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onPressed: () => _getImage(ImageSource.gallery),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildActionBtnModern(
                  icon: Icons.camera_alt_rounded,
                  label: "Take Photo",
                  onPressed: () => _getImage(ImageSource.camera),
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtnModern({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.primaryGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Plant Identified",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.oliveGreen,
                  ),
                ),
                Text(
                  "Healthy & Thriving",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}