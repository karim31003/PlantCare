// lib/features/profile/presentation/addresses_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  // Placeholder addresses list — in production connect to Supabase
  final List<Map<String, String>> _addresses = [
    {
      'label': 'Home',
      'address': '123 Garden Street, Cairo, Egypt',
      'phone': '+20 123 456 7890',
    },
  ];

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
        title: Text('Saved Addresses',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showAddAddressSheet(context),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? _buildEmpty(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._addresses.asMap().entries.map((e) =>
                    _buildAddressCard(context, e.value, e.key)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showAddAddressSheet(context),
                  icon: const Icon(Icons.add_location_alt_outlined,
                      color: AppTheme.primaryGreen),
                  label: Text('Add New Address',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddressCard(
      BuildContext context, Map<String, String> addr, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home_rounded,
                        color: AppTheme.primaryGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(addr['label']!,
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: Color(0xFF878787)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.red),
                onPressed: () => setState(() => _addresses.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _addrRow(Icons.location_on_outlined, addr['address']!),
          const SizedBox(height: 6),
          _addrRow(Icons.phone_outlined, addr['phone']!),
        ],
      ),
    );
  }

  Widget _addrRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF878787)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF0F1111)))),
        ],
      );

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 56, color: Color(0xFFBDBDBD)),
            const SizedBox(height: 16),
            Text('No addresses saved',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F1111))),
            const SizedBox(height: 8),
            Text('Add a delivery address to get started',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: const Color(0xFF878787))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressSheet(context),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );

  void _showAddAddressSheet(BuildContext context) {
    final labelCtrl   = TextEditingController(text: 'Home');
    final addrCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Address',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                    labelText: 'Label (e.g. Home, Work)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (addrCtrl.text.isNotEmpty) {
                      setState(() {
                        _addresses.add({
                          'label': labelCtrl.text,
                          'address': addrCtrl.text,
                          'phone': phoneCtrl.text,
                        });
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Save Address',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
