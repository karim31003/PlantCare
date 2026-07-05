import 'package:flutter/material.dart';
import '../models/checkout_data.dart';
import 'section_card.dart';
import 'checkout_textfield.dart';

class ContactSection extends StatelessWidget {
  final CheckoutControllers controllers;

  const ContactSection({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Contact Information',
      icon: Icons.person_outline_rounded,
      children: [
        CheckoutTextField(
          controller: controllers.fullNameCtrl,
          label: 'Full Name',
          hint: 'John Doe',
          icon: Icons.person_outline_rounded,
          autofillHints: const [AutofillHints.name],
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        CheckoutTextField(
          controller: controllers.phoneCtrl,
          label: 'Phone Number',
          hint: '+20 100 000 0000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Phone is required' : null,
        ),
      ],
    );
  }
}
