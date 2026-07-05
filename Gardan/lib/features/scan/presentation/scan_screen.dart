// lib/presentation/screens/scan/scan_screen.dart

import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/scans_provider.dart';
import 'package:gardain/presentation/providers/plants_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/scan.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  File? _image;
  final _picker = ImagePicker();

  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  late AnimationController _fadeController;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScansProvider>().fetchScans();
      context.read<PlantsProvider>().fetchPlants();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanLineController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Image pick + analyse ─────────────────────────────────────────────────

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() => _image = file);
    _fadeController.forward(from: 0);

    final success =
        await context.read<ScansProvider>().analyzeImage(file, null);
    if (!mounted) return;

    if (success) {
      _showResultSheet();
    } else {
      final err = context.read<ScansProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err ?? 'Analysis failed. Please try again.',
            style: GoogleFonts.outfit(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool _isHealthy(Scan scan) {
    final name = scan.diseaseName.toLowerCase();
    return name.contains('healthy') ||
        name.contains('no disease') ||
        name.contains('none');
  }

  String _confidenceLabel(double? confidence) {
    if (confidence == null) return '—';
    final pct = confidence <= 1.0 ? confidence * 100 : confidence;
    return '${pct.toStringAsFixed(1)}%';
  }

  String _formattedDate(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScansProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(provider),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _image == null
                  ? _buildEmptyState()
                  : _buildImagePreview(provider.isAnalyzing),
            ),
            _buildActionBar(provider.isAnalyzing),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(ScansProvider provider) {
    return AppBar(
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppTheme.oliveGreen,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Plant Diagnosis",
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                color: AppTheme.oliveGreen.withOpacity(0.55),
                onPressed: () => _showHistorySheet(provider.scans),
              ),
              if (provider.scans.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing rings + icon
            Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(2, (i) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale:
                          1.0 + (_pulseController.value * (0.18 + i * 0.1)),
                      child: Container(
                        width: 140.0 + i * 44,
                        height: 140.0 + i * 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGreen
                                .withOpacity(0.09 - i * 0.03),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.18),
                        AppTheme.lightLime.withOpacity(0.28),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_center_focus_rounded,
                    size: 42,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              "Ready to diagnose?",
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
              "Take or upload a photo of a leaf and our AI will detect diseases and suggest treatment.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppTheme.oliveGreen.withOpacity(0.55),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Image preview ────────────────────────────────────────────────────────

  Widget _buildImagePreview(bool isAnalyzing) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          FadeTransition(
            opacity: _fadeController,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
          ),

          // Scan animation overlay
          if (isAnalyzing) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, _) {
                  final yPos = _scanLineController.value *
                      MediaQuery.of(context).size.height *
                      0.5;
                  return Stack(
                    children: [
                      // Glow above line
                      Positioned(
                        top: yPos - 40,
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
                                AppTheme.lightLime.withOpacity(0.18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Scan line
                      Positioned(
                        top: yPos,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.lightLime,
                                AppTheme.lightLime,
                                Colors.transparent,
                              ],
                              stops: const [0, 0.25, 0.75, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.lightLime.withOpacity(0.6),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Analyzing pill
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Analyzing leaf…",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Checking for diseases",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.oliveGreen.withOpacity(0.45),
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

  // ─── Action bar ───────────────────────────────────────────────────────────

  Widget _buildActionBar(bool isAnalyzing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: _image != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clear button
          if (_image != null && !isAnalyzing)
            GestureDetector(
              onTap: () => setState(() => _image = null),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Clear Photo",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.oliveGreen.withOpacity(0.38),
                  ),
                ),
              ),
            ),

          Row(
            children: [
              // Gallery
              Expanded(
                child: _actionBtn(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  isPrimary: false,
                  disabled: isAnalyzing,
                  onPressed: () => _pickAndAnalyze(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 14),
              // Camera
              Expanded(
                flex: 2,
                child: _actionBtn(
                  icon: Icons.camera_alt_rounded,
                  label: "Take Photo",
                  isPrimary: true,
                  disabled: isAnalyzing,
                  onPressed: () => _pickAndAnalyze(ImageSource.camera),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool disabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedOpacity(
        opacity: disabled ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppTheme.primaryGreen
                : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
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
      ),
    );
  }

  // ─── Result sheet ─────────────────────────────────────────────────────────

  void _showResultSheet() {
    final scan = context.read<ScansProvider>().latestScan;
    if (scan == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        scan: scan,
        isHealthy: _isHealthy(scan),
        confidenceLabel: _confidenceLabel(scan.confidence),
        onScanAgain: () {
          Navigator.pop(context);
          setState(() => _image = null);
        },
      ),
    );
  }

  // ─── History sheet ────────────────────────────────────────────────────────

  void _showHistorySheet(List<Scan> scans) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Scan History",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.oliveGreen,
                      ),
                    ),
                    Text(
                      "${scans.length} scans",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.oliveGreen.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: scans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded,
                                size: 52,
                                color:
                                    AppTheme.oliveGreen.withOpacity(0.15)),
                            const SizedBox(height: 12),
                            Text(
                              "No scans yet",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color:
                                    AppTheme.oliveGreen.withOpacity(0.35),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(
                            24, 0, 24, 40),
                        itemCount: scans.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _historyCard(ctx, scans[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyCard(BuildContext sheetCtx, Scan scan) {
    final healthy = _isHealthy(scan);
    final statusColor =
        healthy ? AppTheme.primaryGreen : const Color(0xFFF59E0B);
    final statusBg = statusColor.withOpacity(0.1);

    return GestureDetector(
      key: Key(scan.id),
      onLongPress: () => _showScanActions(scan),
      child: Dismissible(
        key: ValueKey('dismiss-${scan.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded,
              color: Colors.white, size: 22),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (d) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text("Delete scan?",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.oliveGreen)),
                  content: Text("This action cannot be undone.",
                      style: GoogleFonts.outfit(
                          color: AppTheme.oliveGreen.withOpacity(0.6))),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(d, false),
                      child: Text("Cancel",
                          style: GoogleFonts.outfit(
                              color: AppTheme.oliveGreen)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(d, true),
                      child: Text("Delete",
                          style: GoogleFonts.outfit(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) =>
            context.read<ScansProvider>().deleteScan(scan.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  healthy
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.diseaseName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.oliveGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formattedDate(scan.createdAt),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.oliveGreen.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Confidence badge
              if (scan.confidence != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _confidenceLabel(scan.confidence),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanActions(Scan scan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  scan.diseaseName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.oliveGreen,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(Icons.local_florist_rounded),
                  title: Text(
                    'Add to plant',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Link this scan to one of your plants',
                    style: GoogleFonts.outfit(),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showPlantPicker(scan);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_rounded, color: Colors.red.shade400),
                  title: Text(
                    'Delete scan',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  subtitle: Text(
                    'Remove this scan from history',
                    style: GoogleFonts.outfit(),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final deleted = await context.read<ScansProvider>().deleteScan(scan.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          deleted ? 'Scan deleted.' : (context.read<ScansProvider>().error ?? 'Could not delete scan.'),
                          style: GoogleFonts.outfit(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPlantPicker(Scan scan) async {
    final plantsProvider = context.read<PlantsProvider>();
    if (plantsProvider.plants.isEmpty) {
      await plantsProvider.fetchPlants();
    }

    if (!mounted) return;

    final plants = plantsProvider.plants;
    if (plants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No plants found. Add a plant first, then try again.',
            style: GoogleFonts.outfit(),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final selectedPlantId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Choose a plant',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color: AppTheme.oliveGreen.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: plants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final plant = plants[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: AppTheme.backgroundLight,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                        child: Icon(
                          Icons.eco_rounded,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      title: Text(
                        plant.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                      subtitle: Text(
                        plant.species ?? 'No species set',
                        style: GoogleFonts.outfit(),
                      ),
                      onTap: () => Navigator.pop(sheetContext, plant.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedPlantId == null) return;

    final saved =
        await context.read<ScansProvider>().updateScanPlant(scan.id, selectedPlantId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Scan linked to plant.' : (context.read<ScansProvider>().error ?? 'Could not link scan.'),
          style: GoogleFonts.outfit(),
        ),
      ),
    );
  }
}

// ─── Result Sheet (separate widget for clarity) ───────────────────────────────

class _ResultSheet extends StatelessWidget {
  final Scan scan;
  final bool isHealthy;
  final String confidenceLabel;
  final VoidCallback onScanAgain;

  const _ResultSheet({
    required this.scan,
    required this.isHealthy,
    required this.confidenceLabel,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor =
        isHealthy ? AppTheme.primaryGreen : const Color(0xFFF59E0B);
    final headerBg = headerColor.withOpacity(0.07);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: true,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
                children: [
                  // ── Status header ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: headerBg,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: headerColor.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: headerColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHealthy
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            color: headerColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHealthy
                                    ? "No Disease Detected"
                                    : "Disease Detected",
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.oliveGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                scan.diseaseName,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: headerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Info cards row ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          label: "Diagnosis",
                          value: scan.diseaseName,
                          icon: Icons.biotech_rounded,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _infoCard(
                          label: "Confidence",
                          value: confidenceLabel,
                          icon: Icons.auto_awesome_rounded,
                          color: AppTheme.lightLime,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Treatment ─────────────────────────────────────
                  if (scan.treatmentSuggestion != null &&
                      scan.treatmentSuggestion!.isNotEmpty) ...[
                    Text(
                      isHealthy ? "Care Tips" : "Recommended Treatment",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.oliveGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.healing_rounded,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              scan.treatmentSuggestion!,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.oliveGreen.withOpacity(0.75),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ── Actions ───────────────────────────────────────
                  _primaryButton(
                    label: "Done",
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: onScanAgain,
                      child: Text(
                        "Scan another plant",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.oliveGreen.withOpacity(0.45),
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

  Widget _infoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.oliveGreen.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.oliveGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.oliveGreen],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.28),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
