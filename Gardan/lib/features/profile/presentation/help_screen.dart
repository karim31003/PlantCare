// lib/features/profile/presentation/help_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
        title: Text('Help & Support',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact us banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6741), Color(0xFF6CA651)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need Help?',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Our support team is here for you',
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contact options
          _sectionLabel('Contact Us'),
          const SizedBox(height: 10),
          _buildCard([
            _buildContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppTheme.primaryGreen,
              title: 'Live Chat',
              subtitle: 'Available 9am – 9pm',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 70),
            _buildContactTile(
              icon: Icons.email_outlined,
              color: const Color(0xFF2196F3),
              title: 'Email Us',
              subtitle: 'support@gardanzaki.com',
              onTap: () => launchUrl(
                  Uri.parse('mailto:support@gardanzaki.com')),
            ),
            const Divider(height: 1, indent: 70),
            _buildContactTile(
              icon: Icons.phone_outlined,
              color: const Color(0xFF4CAF50),
              title: 'Call Us',
              subtitle: '+20 123 456 7890',
              onTap: () =>
                  launchUrl(Uri.parse('tel:+201234567890')),
            ),
          ]),

          const SizedBox(height: 20),

          // FAQs
          _sectionLabel('Frequently Asked Questions'),
          const SizedBox(height: 10),
          ..._faqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I track my order?',
      'a': 'Go to Your Orders from the Profile menu. Tap any order to see real-time tracking with live status updates.',
    },
    {
      'q': 'How do I add a plant to my collection?',
      'a': 'Tap the Plants tab at the bottom, then tap the + button. You can enter details manually or use the AI scanner.',
    },
    {
      'q': 'How does the plant disease scanner work?',
      'a': 'Open the Scan tab and point your camera at a plant leaf. Our AI model will analyze and detect any diseases or issues.',
    },
    {
      'q': 'Can I cancel my order?',
      'a': 'Yes! Open the order tracking screen and tap Cancel Order. Cancellation is only available when the order is in Pending status.',
    },
    {
      'q': 'How do I set watering reminders?',
      'a': 'Open any plant in your collection, scroll to the Reminders section, and set your preferred watering schedule.',
    },
  ];

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF565959),
          letterSpacing: 0.3));

  Widget _buildCard(List<Widget> children) => Container(
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
        child: Column(children: children),
      );

  Widget _buildContactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F1111))),
                      Text(subtitle,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF878787))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFBDBDBD), size: 22),
              ],
            ),
          ),
        ),
      );

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.help_outline_rounded,
              color: AppTheme.primaryGreen, size: 18),
        ),
        title: Text(question,
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F1111))),
        iconColor: AppTheme.primaryGreen,
        collapsedIconColor: const Color(0xFFBDBDBD),
        children: [
          Text(answer,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF565959),
                  height: 1.6)),
        ],
      ),
    );
  }
}
