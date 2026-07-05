// lib/presentation/screens/plants/plant_detail_screen.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/plants_provider.dart';
import 'package:gardain/presentation/providers/scans_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/plant.dart';
import 'edit_plant_screen.dart';

// ─── Helper: render any imageUrl (local path or remote URL) ─────────────────
Widget _buildPlantImage({
  required String imageUrl,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext)? placeholder,
  Widget Function(BuildContext)? errorWidget,
}) {
  return Builder(
    builder: (context) {
      final ph = placeholder ?? (_) => Container(color: AppTheme.lightLime.withOpacity(0.2));
      final err = errorWidget ??
          (_) => Container(
                color: AppTheme.lightLime.withOpacity(0.2),
                child: const Center(
                  child:
                      Icon(Icons.local_florist, size: 80, color: AppTheme.primaryGreen),
                ),
              );

      if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
        // Local file picked from gallery
        final file = File(imageUrl.replaceFirst('file://', ''));
        return SizedBox(
          height: height,
          width: double.infinity,
          child: file.existsSync()
              ? Image.file(file, fit: fit, height: height, width: double.infinity)
              : err(context),
        );
      }

      // Remote URL
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        placeholder: (ctx, _) => ph(ctx),
        errorWidget: (ctx, _, __) => err(ctx),
      );
    },
  );
}

// ─── Last-watered label helpers ───────────────────────────────────────────────
String _lastWateredRelative(DateTime lastWatered) {
  final diff = DateTime.now().difference(lastWatered);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 14) return 'A week ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
  return '${(diff.inDays / 30).floor()} months ago';
}

String _lastWateredExact(DateTime lastWatered) {
  final now = DateTime.now();
  final sameYear = now.year == lastWatered.year;
  final months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  final h = lastWatered.hour.toString().padLeft(2, '0');
  final m = lastWatered.minute.toString().padLeft(2, '0');
  return sameYear
      ? '${lastWatered.day} ${months[lastWatered.month - 1]}, $h:$m'
      : '${lastWatered.day} ${months[lastWatered.month - 1]} ${lastWatered.year}, $h:$m';
}

/// Next-watering label: overdue, due today, or "in X days"
String _nextWateringLabel(DateTime lastWatered, double frequencyDays) {
  final nextWatering = lastWatered.add(
    Duration(minutes: (frequencyDays * 24 * 60).round()),
  );
  final diff = nextWatering.difference(DateTime.now());
  if (diff.isNegative) {
    final overdue = diff.abs();
    if (overdue.inMinutes < 60) return 'Overdue by ${overdue.inMinutes} min';
    if (overdue.inHours < 24) return 'Overdue by ${overdue.inHours} h';
    return 'Overdue by ${overdue.inDays} day${overdue.inDays == 1 ? '' : 's'}';
  }
  if (diff.inHours < 1) return 'Due in ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Due in ${diff.inHours} h';
  if (diff.inDays == 0) return 'Due today';
  if (diff.inDays == 1) return 'Due tomorrow';
  return 'In ${diff.inDays} days';
}

bool _isOverdue(DateTime lastWatered, double frequencyDays) {
  final nextWatering = lastWatered.add(
    Duration(minutes: (frequencyDays * 24 * 60).round()),
  );
  return nextWatering.isBefore(DateTime.now());
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? _plant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScansProvider>().fetchScansByPlant(widget.plantId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plant = context.read<PlantsProvider>().plants.firstWhere(
          (p) => p.id == widget.plantId,
          orElse: () => Plant(
  id: widget.plantId,
  userId: '',
  name: 'Unknown',
  species: null,
  imageUrl: null,
  lastWatered: null,
  wateringFrequency: const Duration(days: 7),
  healthStatus: 'Healthy',
  createdAt: DateTime.now(),
),
        );
  }

  Future<void> _markAsWatered() async {
    final success =
        await context.read<PlantsProvider>().markAsWatered(widget.plantId);
    if (!mounted) return;
    if (success) {
      setState(() {
        _plant = context.read<PlantsProvider>().plants.firstWhere(
              (p) => p.id == widget.plantId,
              orElse: () => _plant!,
            );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Marked as watered!')),
      );
    }
  }

  Future<void> _deletePlant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Plant',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to remove ${_plant?.name}?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success =
        await context.read<PlantsProvider>().deletePlant(widget.plantId);
    if (!mounted) return;

    if (success) {
      context.go('/plants');
    } else {
      final error = context.read<PlantsProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to delete plant')),
      );
    }
  }

  void _openEditScreen() async {
    if (_plant == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<PlantsProvider>(),
          child: EditPlantScreen(plant: _plant!),
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _plant = context.read<PlantsProvider>().plants.firstWhere(
              (p) => p.id == widget.plantId,
              orElse: () => _plant!,
            );
      });
    }
  }

  void _openFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullImageScreen(
            imageUrl: imageUrl, plantName: _plant?.name ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    if (plant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isHealthy = plant.healthStatus == 'Healthy';
    final statusColor = isHealthy ? AppTheme.primaryGreen : AppTheme.darkLime;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(plant, statusColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(plant, statusColor),
                  const SizedBox(height: 20),
                  _buildWateringCard(plant),
                  const SizedBox(height: 20),
                  _buildMarkWateredButton(),
                  const SizedBox(height: 32),
                  _buildScanHistorySection(),
                  const SizedBox(height: 20),
                  _buildEditButton(),
                  const SizedBox(height: 12),
                  _buildDeleteButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(Plant plant, Color statusColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.backgroundLight,
      leading: GestureDetector(
        onTap: () => context.go('/plants'),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.oliveGreen, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _openEditScreen,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_rounded,
                    color: AppTheme.oliveGreen, size: 16),
                const SizedBox(width: 4),
                Text('Edit',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.oliveGreen)),
              ],
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: plant.imageUrl != null
              ? () => _openFullImage(plant.imageUrl!)
              : null,
          child: plant.imageUrl != null
              ? Hero(
                  tag: 'plant_image_${plant.id}',
                  // ✅ Fixed: handles local paths AND remote URLs
                  child: _buildPlantImage(
                    imageUrl: plant.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_) => Container(
                      color: AppTheme.lightLime.withOpacity(0.2),
                      child:
                          const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_) => _buildPlaceholderImage(),
                  ),
                )
              : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.lightLime.withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.local_florist, size: 80, color: AppTheme.primaryGreen),
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────────────────
  Widget _buildInfoCard(Plant plant, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(plant.name,
                    style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.oliveGreen)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withOpacity(0.3), width: 1),
                ),
                child: Text(plant.healthStatus,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (plant.species != null) ...[
            const SizedBox(height: 6),
            Text(plant.species!,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400)),
          ],
        ],
      ),
    );
  }

  // ── Watering card ────────────────────────────────────────────────────────
  Widget _buildWateringCard(Plant plant) {
    final lastWatered = plant.lastWatered;
final freqDuration = plant.wateringFrequency;
final freqDays = freqDuration.inHours / 24;

    // ── Last-watered section ─────────────────────────────────────────
    final String lastWateredTop;
    final String lastWateredSub;
    final Color lastWateredColor;

    if (lastWatered == null) {
      lastWateredTop = 'Never';
      lastWateredSub = 'No record yet';
      lastWateredColor = const Color(0xFF9CA3AF);
    } else {
      lastWateredTop = _lastWateredRelative(lastWatered);
      lastWateredSub = _lastWateredExact(lastWatered);
      lastWateredColor = AppTheme.darkLime;
    }

    // ── Next-watering section ────────────────────────────────────────
    final String nextTop;
    final String nextSub;
    final Color nextColor;

    if (lastWatered == null) {
      nextTop = '—';
      nextSub = 'Water it first';
      nextColor = const Color(0xFF9CA3AF);
    } else {
      final overdue = _isOverdue(lastWatered, freqDays);
      nextTop = _nextWateringLabel(lastWatered, freqDays);
      nextColor = overdue ? Colors.red : AppTheme.primaryGreen;
      nextSub = overdue ? 'Needs water now!' : 'Stay on schedule';
    }

    // ── Frequency display ────────────────────────────────────────────
 final days = freqDuration.inDays;
final hours = freqDuration.inHours % 24;

String freqLabel;

if (days > 0 && hours > 0) {
  freqLabel =
      'Every $days day${days > 1 ? 's' : ''} and $hours hour${hours > 1 ? 's' : ''}';
} else if (days > 0) {
  if (days % 7 == 0) {
    final weeks = days ~/ 7;
    freqLabel = weeks == 1
        ? 'Weekly'
        : 'Every $weeks weeks';
  } else if (days == 1) {
    freqLabel = 'Every day';
  } else {
    freqLabel = 'Every $days days';
  }
} else {
  freqLabel =
      'Every $hours hour${hours > 1 ? 's' : ''}';
}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Watering Info',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.oliveGreen)),
          const SizedBox(height: 16),

          // Last watered + next watering
          Row(
            children: [
              Expanded(
                child: _buildWateringMetric(
                  icon: Icons.water_drop_rounded,
                  label: 'Last Watered',
                  topValue: lastWateredTop,
                  subValue: lastWateredSub,
                  color: lastWateredColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWateringMetric(
                  icon: Icons.schedule_rounded,
                  label: 'Next Watering',
                  topValue: nextTop,
                  subValue: nextSub,
                  color: nextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Frequency chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.repeat_rounded,
                    color: AppTheme.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Text(freqLabel,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWateringMetric({
    required IconData icon,
    required String label,
    required String topValue,
    required String subValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(topValue,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.oliveGreen)),
          const SizedBox(height: 2),
          Text(subValue,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  // ── Mark as watered ──────────────────────────────────────────────────────
  Widget _buildMarkWateredButton() {
    final isLoading = context.watch<PlantsProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading ? null : _markAsWatered,
        icon: const Icon(Icons.water_drop_rounded, size: 20),
        label: Text('Mark as Watered',
            style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Scan history ─────────────────────────────────────────────────────────
  Widget _buildScanHistorySection() {
    final scansProvider = context.watch<ScansProvider>();
    final scans = scansProvider.scans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Scan History',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.oliveGreen,
                    letterSpacing: -0.2)),
            TextButton.icon(
              onPressed: () => context.go('/scan'),
              icon: const Icon(Icons.qr_code_scanner,
                  size: 16, color: AppTheme.primaryGreen),
              label: Text('New Scan',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (scansProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (scans.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Column(
              children: [
                const Icon(Icons.document_scanner_outlined,
                    size: 40, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 8),
                Text('No scans yet',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          )
        else
          ...scans.map((scan) {
            final isHealthy = scan.diseaseName == 'Healthy';
            final statusColor =
                isHealthy ? AppTheme.primaryGreen : Colors.orange;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE5E7EB), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHealthy
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scan.diseaseName,
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.oliveGreen)),
                        if (scan.treatmentSuggestion != null)
                          Text(scan.treatmentSuggestion!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  if (scan.confidence != null)
                    Text(
                        '${(scan.confidence! * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Edit / Delete buttons ────────────────────────────────────────────────
  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryGreen,
          side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _openEditScreen,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: Text('Edit Plant',
            style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _deletePlant,
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
        label: Text('Remove Plant',
            style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Full-screen image viewer ────────────────────────────────────────────────
class _FullImageScreen extends StatelessWidget {
  final String imageUrl;
  final String plantName;
  const _FullImageScreen(
      {required this.imageUrl, required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(plantName,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: 'plant_image_$imageUrl',
            // ✅ Fixed: handles both local and remote
            child: _buildPlantImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_) =>
                  const CircularProgressIndicator(color: Colors.white),
              errorWidget: (_) => const Icon(Icons.broken_image,
                  color: Colors.white, size: 60),
            ),
          ),
        ),
      ),
    );
  }
}