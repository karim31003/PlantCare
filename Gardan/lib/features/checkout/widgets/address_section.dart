import 'package:flutter/material.dart';
import '../models/checkout_data.dart';
import 'section_card.dart';
import 'checkout_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

const List<String> egyptianGovernorates = [
  'Cairo', 'Alexandria', 'Giza', 'Shubra El Kheima', 'Port Said', 'Suez', 
  'Luxor', 'Mansoura', 'El-Mahalla El-Kubra', 'Tanta', 'Asyut', 'Ismailia', 
  'Fayyum', 'Zagazig', 'Aswan', 'Damietta', 'Damanhur', 'Minya', 'Beni Suef', 
  'Qena', 'Sohag', 'Hurghada', '6th of October', 'Shibin El Kom', 'Banha', 
  'Kafr El Sheikh', 'Arish', 'Mallawi', '10th of Ramadan', 'Bilbais', 
  'Marsa Matruh', 'Idfu', 'Mit Ghamr', 'Al-Hamidiyya', 'Desouk', 'Qalyub', 
  'Abu Kabir', 'Kafr El Dawwar', 'Girga', 'Akhmim', 'Matareya'
];

class AddressSection extends StatelessWidget {
  final CheckoutControllers controllers;

  const AddressSection({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Delivery Address',
          icon: Icons.location_on_outlined,
          children: [
            CheckoutTextField(
              controller: controllers.streetCtrl,
              label: 'Street Address',
              hint: '123 Main St, Building A',
              icon: Icons.home_outlined,
              autofillHints: const [AutofillHints.streetAddressLine1],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Street is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controllers.stateCtrl.text.isEmpty ? null : controllers.stateCtrl.text,
              items: egyptianGovernorates.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controllers.stateCtrl.text = newValue;
                }
              },
              validator: (v) => v == null || v.trim().isEmpty ? 'Governorate is required' : null,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF0F1111),
              ),
              decoration: InputDecoration(
                labelText: 'Governorate',
                hintText: 'Select Governorate',
                prefixIcon: const Icon(
                  Icons.map_outlined,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
                labelStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
                hintStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryGreen,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Order Notes',
          icon: Icons.notes_rounded,
          optional: true,
          children: [
            CheckoutTextField(
              controller: controllers.notesCtrl,
              label: 'Special Instructions',
              hint: 'Delivery instructions, gate code, etc.',
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
          ],
        ),
      ],
    );
  }
}
