import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gardain/core/utils/image_utils.dart';
import 'package:gardain/presentation/providers/plants_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/plant.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;

  const EditPlantScreen({super.key, required this.plant});

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _imageUrlController;
  late Duration _wateringDuration;
  late String _healthStatus;
  final List<String> _healthOptions = ['Healthy', 'Needs Attention', 'Critical'];

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _speciesController = TextEditingController(text: widget.plant.species ?? '');
    _imageUrlController = TextEditingController(text: widget.plant.imageUrl ?? '');
    _wateringDuration = widget.plant.wateringFrequency;
    _healthStatus = widget.plant.healthStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ─── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
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
                child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryGreen),
              ),
              title: Text('Camera', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('Take a new photo',
                  style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF))),
            ),
            ListTile(
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryGreen),
              ),
              title: Text('Gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('Choose from library',
                  style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF))),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await ImageUtils.pickDirect(source: source);
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _imageUrlController.clear();
    });
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.plant.copyWith(
      name: _nameController.text.trim(),
      species: _speciesController.text.trim().isEmpty
          ? null
          : _speciesController.text.trim(),
      wateringFrequency: _wateringDuration,
      healthStatus: _healthStatus,
      imageUrl: _selectedImage != null ? null : _imageUrlController.text.trim(),
      newImagePath: _selectedImage?.path,
    );

    final success = await context.read<PlantsProvider>().updatePlant(updated);

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final error = context.read<PlantsProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to update plant')),
      );
    }
  }

  // ─── Watering helpers ──────────────────────────────────────────────────────

  String _formatWateringDuration() {
    final days = _wateringDuration.inDays;
    if (days == 1) return 'Every day';
    return 'Every $days days';
  }

  Future<void> _pickWateringDuration() async {
    int selectedDays = _wateringDuration.inDays.clamp(1, 7);

    final result = await showDialog<Duration>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(
            'Watering Frequency',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: DropdownButtonFormField<int>(
            value: selectedDays,
            decoration: const InputDecoration(labelText: 'Days'),
            items: List.generate(
              7,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: (v) => setModalState(() => selectedDays = v ?? 1),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, Duration(days: selectedDays)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) setState(() => _wateringDuration = result);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PlantsProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.oliveGreen, size: 18),
          ),
        ),
        title: Text(
          'Edit Plant',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.oliveGreen,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: isLoading ? null : _save,
              child: Text(
                'Save',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Info card ──────────────────────────────────────────────
            _buildCard(children: [
              _buildField(
                controller: _nameController,
                label: 'Plant Name',
                hint: 'e.g. My Monstera',
                icon: Icons.local_florist_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _speciesController,
                label: 'Species (optional)',
                hint: 'e.g. Monstera deliciosa',
                icon: Icons.eco_rounded,
              ),
              const SizedBox(height: 16),

              // ── Image section ────────────────────────────────────────
              Text(
                'Plant Image',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.oliveGreen,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover,
                            width: double.infinity)
                        : (widget.plant.imageUrl != null &&
                                widget.plant.imageUrl!.isNotEmpty)
                            ? Image.network(widget.plant.imageUrl!,
                                fit: BoxFit.cover, width: double.infinity)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_rounded,
                                      size: 40, color: AppTheme.primaryGreen),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to choose an image',
                                    style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Image action buttons ─────────────────────────────────
              Row(
                children: [
                  if (_selectedImage != null)
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await ImageUtils.pickDirect(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) setState(() => _selectedImage = picked);
                      },
                      icon: const Icon(Icons.tune_rounded, size: 14),
                      label: Text('Edit photo',
                          style: GoogleFonts.outfit(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen),
                    ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_rounded, size: 14),
                    label: Text(
                      _selectedImage != null ||
                              (widget.plant.imageUrl != null &&
                                  widget.plant.imageUrl!.isNotEmpty)
                          ? 'Change image'
                          : 'Add image',
                      style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.oliveGreen),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 20),

            // ── Watering card ──────────────────────────────────────────
            _buildCard(children: [
              Text(
                'Watering Frequency',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.oliveGreen,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickWateringDuration,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop_rounded,
                          color: AppTheme.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatWateringDuration(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.oliveGreen,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right_rounded,
                          color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),
              Slider(
                value: _wateringDuration.inDays.clamp(1, 7).toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                activeColor: AppTheme.primaryGreen,
                inactiveColor: AppTheme.primaryGreen.withOpacity(0.2),
                onChanged: (v) =>
                    setState(() => _wateringDuration = Duration(days: v.round())),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 day',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: const Color(0xFF9CA3AF))),
                  Text('7 days',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: const Color(0xFF9CA3AF))),
                ],
              ),
            ]),

            const SizedBox(height: 20),

            // ── Health card ────────────────────────────────────────────
            _buildCard(children: [
              Text(
                'Health Status',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.oliveGreen,
                ),
              ),
              const SizedBox(height: 12),
              ..._healthOptions.map((option) {
                final selected = _healthStatus == option;
                final color = option == 'Healthy'
                    ? AppTheme.primaryGreen
                    : option == 'Needs Attention'
                        ? Colors.orange
                        : Colors.red;
                return GestureDetector(
                  onTap: () => setState(() => _healthStatus = option),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? color.withOpacity(0.4)
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected ? color : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected ? color : AppTheme.oliveGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ]),

            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading ? null : _save,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.oliveGreen,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.oliveGreen),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                fontSize: 14, color: const Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
