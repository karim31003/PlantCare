// lib/features/profile/presentation/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        backgroundColor: AppTheme.oliveGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Payment Methods',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active method
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.primaryGreen, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments_rounded,
                      color: Color(0xFFF0A500), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cash on Delivery',
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F1111))),
                      Text('Pay when you receive your order',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF878787))),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primaryGreen, size: 22),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Coming soon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.credit_card_outlined,
                    size: 40, color: Color(0xFFBDBDBD)),
                const SizedBox(height: 12),
                Text('More Payment Methods',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F1111))),
                const SizedBox(height: 6),
                Text('Credit/Debit cards and online payment coming soon',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: const Color(0xFF878787),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
