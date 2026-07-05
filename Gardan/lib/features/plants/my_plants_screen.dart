// lib/presentation/screens/plants/plants_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gardain/core/utils/image_utils.dart';
import 'package:gardain/data/services/storage_service.dart';
import 'package:gardain/presentation/providers/plants_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/plant.dart';
import 'package:uuid/uuid.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  int _selectedFilterIndex = 0;

  static const _filters = ['All Plants', 'Needs Water', 'Healthy', 'Needs Care'];
  static const _filterIcons = [
    Icons.yard_rounded,
    Icons.water_drop_rounded,
    Icons.check_circle_rounded,
    Icons.healing_rounded,
  ];

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantsProvider>().fetchPlants();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<Plant> _filteredPlants(List<Plant> plants) {
    switch (_selectedFilterIndex) {
      case 1:
        return plants
            .where((p) =>
                p.healthStatus == 'Needs Water' || _daysUntilWater(p) < 0)
            .toList();
      case 2:
        return plants.where((p) => p.healthStatus == 'Healthy').toList();
      case 3:
        return plants.where((p) => p.healthStatus == 'Needs Care').toList();
      default:
        return plants;
    }
  }

  /// Returns days until next watering. Negative = overdue.
  int _daysUntilWater(Plant plant) {
  if (plant.lastWatered == null) {
    return -999;
  }

  final next = plant.lastWatered!
      .add(plant.wateringFrequency);

  return next.difference(DateTime.now()).inDays;
}

  String _wateringLabel(Plant plant) {
    final days = _daysUntilWater(plant);
    if (plant.lastWatered == null) return 'Not set';
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Needs Water':
        return const Color(0xFF60A5FA);
      case 'Needs Care':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.primaryGreen;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlantsProvider>();
    final allPlants = provider.plants;
    final filtered = _filteredPlants(allPlants);

    // Surface errors as a snackbar without blocking UI
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!, style: GoogleFonts.outfit()),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.read<PlantsProvider>().clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.lightLime,
        foregroundColor: AppTheme.oliveGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _showAddPlantSheet(context),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            FadeTransition(
              opacity: _headerController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _headerController, curve: Curves.easeOut)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
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
                            provider.isLoading && allPlants.isEmpty
                                ? "Loading your plants…"
                                : "${allPlants.length} ${allPlants.length == 1 ? 'plant' : 'plants'} in your collection",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.oliveGreen.withOpacity(0.55),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      // Subtle refresh indicator / button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: provider.isLoading
                            ? Padding(
                                key: const ValueKey('loading'),
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryGreen.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : IconButton(
                                key: const ValueKey('refresh'),
                                onPressed: () =>
                                    context.read<PlantsProvider>().fetchPlants(),
                                icon: const Icon(Icons.refresh_rounded),
                                color: AppTheme.oliveGreen.withOpacity(0.35),
                                splashRadius: 20,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Chips ─────────────────────────────────────────────
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _filters.length,
                itemBuilder: (_, i) =>
                    _filterChip(_filters[i], _filterIcons[i], i),
              ),
            ),

            const SizedBox(height: 20),

            // ── Grid / States ─────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: provider.isLoading && allPlants.isEmpty
                    ? _buildSkeletonGrid(key: const ValueKey('skeleton'))
                    : filtered.isEmpty
                        ? _buildEmptyState(
                            key: const ValueKey('empty'),
                            isFiltered: _selectedFilterIndex != 0,
                          )
                        : _buildGrid(filtered, key: const ValueKey('grid')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Grid ─────────────────────────────────────────────────────────────────

  Widget _buildGrid(List<Plant> plants, {Key? key}) {
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
      itemCount: plants.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, i) => _plantCard(plants[i]),
    );
  }

  // ─── Plant Card ───────────────────────────────────────────────────────────

  Widget _plantCard(Plant plant) {
    final label = _wateringLabel(plant);
    final isOverdue = label == 'Overdue';
    final statusColor = _statusColor(plant.healthStatus);

    return Dismissible(
      key: Key(plant.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) => _confirmDelete(plant.name),
      onDismissed: (_) =>
          context.read<PlantsProvider>().deletePlant(plant.id),
      child: GestureDetector(
        onTap: () => context.push('/plants/${plant.id}'),
        child: Container(
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
                // ── Image + badges ──────────────────────────────────────
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: plant.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: plant.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _imagePlaceholder(),
                              errorWidget: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),

                    // Subtle gradient for badge readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.06),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                            stops: const [0, 0.2, 0.8, 1],
                          ),
                        ),
                      ),
                    ),

                    // Status badge — top left
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              plant.healthStatus,
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
                    ),

                    // Water-now button — top right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _markWatered(plant),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? const Color(0xFF60A5FA).withOpacity(0.92)
                                : AppTheme.white.withOpacity(0.88),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.water_drop_rounded,
                            size: 16,
                            color: isOverdue
                                ? Colors.white
                                : AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Info ────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
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
                          plant.species ?? 'Unknown species',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NEXT WATER",
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
                                  color: isOverdue
                                      ? Colors.red.shade400
                                      : AppTheme.primaryGreen,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isOverdue
                                        ? Colors.red.shade400
                                        : AppTheme.oliveGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Mark as watered ──────────────────────────────────────────────────────

  Future<void> _markWatered(Plant plant) async {
  if (plant.id == null || plant.id!.isEmpty) return;

  final success =
      await context.read<PlantsProvider>().markAsWatered(plant.id!);
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? "${plant.name} watered! 💧" : "Could not update. Try again.",
        style: GoogleFonts.outfit(),
      ),
      backgroundColor:
          success ? AppTheme.primaryGreen : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}

  // ─── Delete confirm dialog ────────────────────────────────────────────────

  Future<bool> _confirmDelete(String plantName) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppTheme.white,
            title: Text(
              "Remove plant?",
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, color: AppTheme.oliveGreen),
            ),
            content: Text(
              '"$plantName" will be permanently deleted.',
              style: GoogleFonts.outfit(
                  color: AppTheme.oliveGreen.withOpacity(0.65)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text("Cancel",
                    style: GoogleFonts.outfit(color: AppTheme.oliveGreen)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  "Delete",
                  style: GoogleFonts.outfit(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ─── Image placeholder ────────────────────────────────────────────────────

  Widget _imagePlaceholder() {
    return Container(
      color: AppTheme.oliveGreen.withOpacity(0.06),
      child: Center(
        child: Icon(
          Icons.local_florist_rounded,
          size: 48,
          color: AppTheme.oliveGreen.withOpacity(0.18),
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState({Key? key, required bool isFiltered}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.local_florist_outlined,
              size: 64,
              color: AppTheme.oliveGreen.withOpacity(0.18),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? "No plants match this filter" : "Your garden is empty",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.oliveGreen.withOpacity(0.45),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? "Try a different filter above"
                  : "Tap + to add your first plant",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.oliveGreen.withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading skeleton ─────────────────────────────────────────────────────

  Widget _buildSkeletonGrid({Key? key}) {
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, __) => _skeletonCard(),
    );
  }

  Widget _skeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(color: AppTheme.oliveGreen.withOpacity(0.06)),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _shimmerBar(width: 100, height: 13),
                    const SizedBox(height: 8),
                    _shimmerBar(width: 70, height: 10),
                    const SizedBox(height: 16),
                    _shimmerBar(width: 60, height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.oliveGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  // ─── Filter chip ──────────────────────────────────────────────────────────

  Widget _filterChip(String text, IconData icon, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
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
                  color: AppTheme.primaryGreen.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? AppTheme.white : AppTheme.oliveGreen,
              ),
              const SizedBox(width: 7),
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

  // ─── Add Plant bottom sheet ───────────────────────────────────────────────

void _showAddPlantSheet(BuildContext context) {
  final nameCtrl = TextEditingController();
  final speciesCtrl = TextEditingController();
  int wateringDays = 7;
  File? selectedImage;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Add a Plant",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Image Picker ──
                  GestureDetector(
                    onTap: () async {
                      final picked = await _pickImage();
                      if (picked != null) setSheet(() => selectedImage = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedImage != null
                              ? AppTheme.primaryGreen
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 36,
                                  color: AppTheme.primaryGreen.withOpacity(0.6),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add plant photo",
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Camera or Gallery",
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: const Color(0xFFD1D5DB),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // ── Show camera/gallery options if image selected ──
                  if (selectedImage != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await _pickImage();
                          if (picked != null) {
                            setSheet(() => selectedImage = picked);
                          }
                        },
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        label: Text(
                          'Change photo',
                          style: GoogleFonts.outfit(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Name
                  _sheetField(
                    nameCtrl,
                    "Plant name *",
                    Icons.local_florist_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Species
                  _sheetField(
                    speciesCtrl,
                    "Species (optional)",
                    Icons.science_rounded,
                    isItalic: true,
                  ),
                  const SizedBox(height: 20),

                  // Watering frequency
                  Text(
                    "Water every",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.oliveGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _freqButton(Icons.remove_rounded, () {
                        if (wateringDays > 1) setSheet(() => wateringDays--);
                      }),
                      const SizedBox(width: 20),
                      Text(
                        "$wateringDays ${wateringDays == 1 ? 'day' : 'days'}",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.oliveGreen,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _freqButton(Icons.add_rounded, () {
                        if (wateringDays < 30) setSheet(() => wateringDays++);
                      }),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Submit
                  Consumer<PlantsProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : () => _submitAddPlant(
                                    sheetCtx: sheetCtx,
                                    nameCtrl: nameCtrl,
                                    speciesCtrl: speciesCtrl,
                                    wateringDays: wateringDays,
                                    imageFile: selectedImage,
                                  ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Add to Garden",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ── Image picker helper ──────────────────────────────────────────────

Future<File?> _pickImage() async {
 final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Photo',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.oliveGreen,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: AppTheme.primaryGreen),
            ),
            title: Text('Camera',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            subtitle: Text('Take a new photo',
                style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF))),
          ),
          ListTile(
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.darkLime.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.darkLime),
            ),
            title: Text('Gallery',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            subtitle: Text('Choose from library',
                style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF))),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (source == null) return null;

  return ImageUtils.pickDirect(source: source);

}
Future<void> _submitAddPlant({
  required BuildContext sheetCtx,
  required TextEditingController nameCtrl,
  required TextEditingController speciesCtrl,
  required int wateringDays,
  File? imageFile,
}) async {
  final name = nameCtrl.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Plant name is required", style: GoogleFonts.outfit()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    return;
  }

  Navigator.of(sheetCtx).pop();

  // Upload image first if selected
  String? imageUrl;
  if (imageFile != null) {
    try {
      imageUrl = await StorageService.uploadPlantImage(imageFile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Image upload failed: $e",
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
  }

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }

  final plant = Plant(
    id: const Uuid().v4(),
    userId: user.id,
    name: name,
    species:
        speciesCtrl.text.trim().isEmpty ? null : speciesCtrl.text.trim(),
    imageUrl: imageUrl,
    lastWatered: null,
    wateringFrequency: Duration(days: wateringDays),
    healthStatus: 'Healthy',
    createdAt: DateTime.now(),
  );

  final success = await context.read<PlantsProvider>().addPlant(plant);
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "$name added to your garden 🌿"
            : context.read<PlantsProvider>().error ?? "Failed to add plant.",
        style: GoogleFonts.outfit(),
      ),
      backgroundColor: success ? AppTheme.primaryGreen : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}
  Widget _sheetField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isItalic = false,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.outfit(
        color: AppTheme.oliveGreen,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF9CA3AF),
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        filled: true,
        fillColor: AppTheme.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _freqButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, color: AppTheme.oliveGreen, size: 20),
      ),
    );
  }
}
