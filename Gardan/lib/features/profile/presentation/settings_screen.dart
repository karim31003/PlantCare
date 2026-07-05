// lib/features/profile/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/api_config_service.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates      = true;
  bool _reminderAlerts    = true;
  bool _promoEmails       = false;
  String _language        = 'English';
  String _apiHost = '';
  final TextEditingController _apiHostController = TextEditingController();
  bool _isTestingConnection = false;
  String _connectionStatus = 'unknown';
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pref_push')    ?? true;
      _orderUpdates      = prefs.getBool('pref_orders')  ?? true;
      _reminderAlerts    = prefs.getBool('pref_reminders')  ?? true;
      _promoEmails       = prefs.getBool('pref_promo')   ?? false;
      _language          = prefs.getString('pref_lang')  ?? 'English';
      _apiHost = ApiConfigService.apiHost ?? '';
      _apiHostController.text = _apiHost;
      _validationError = _validateHostInput(_apiHost);
    });
    _checkConnectionSilently();
  }

  @override
  void dispose() {
    _apiHostController.dispose();
    super.dispose();
  }

  Future<void> _setPref(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _setLang(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_lang', val);
  }

  Future<void> _checkConnectionSilently() async {
    if (!mounted) return;
    setState(() => _connectionStatus = 'checking');
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.flaskBaseUrl}/health'))
          .timeout(const Duration(seconds: 4));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _connectionStatus = 'online');
      } else {
        setState(() => _connectionStatus = 'offline');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _connectionStatus = 'offline');
    }
  }

  String? _validateHostInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    
    final uriStr = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    final uri = Uri.tryParse(uriStr);
    
    if (uri == null || uri.host.isEmpty) {
      return 'Invalid host or URL format.';
    }
    
    final host = uri.host;
    final ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    final hostPattern = RegExp(r'^[a-zA-Z0-9\-\.]+$');
    
    if (!ipPattern.hasMatch(host) && !hostPattern.hasMatch(host)) {
      return 'Host contains invalid characters.';
    }
    
    if (ipPattern.hasMatch(host)) {
      final parts = host.split('.');
      for (var part in parts) {
        final val = int.tryParse(part);
        if (val == null || val < 0 || val > 255) {
          return 'Invalid IP address octet: $part';
        }
      }
    }
    
    return null;
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;
    
    switch (_connectionStatus) {
      case 'online':
        color = Colors.green.shade600;
        label = 'Online';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'offline':
        color = Colors.red.shade600;
        label = 'Offline';
        icon = Icons.error_outline_rounded;
        break;
      case 'checking':
        color = Colors.orange.shade600;
        label = 'Checking...';
        icon = Icons.sync;
        break;
      default:
        color = Colors.grey.shade600;
        label = 'Unknown';
        icon = Icons.help_outline_rounded;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_connectionStatus == 'checking')
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = 'checking';
    });

    try {
      final response = await http
          .get(Uri.parse('${AppConfig.flaskBaseUrl}/health'))
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _connectionStatus = 'online');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Text(
              'Connection OK: ${AppConfig.flaskBaseUrl}',
              style: GoogleFonts.outfit(),
            ),
          ),
        );
      } else {
        setState(() => _connectionStatus = 'offline');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text(
              'Host reachable, but /health returned ${response.statusCode}.',
              style: GoogleFonts.outfit(),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _connectionStatus = 'offline');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(
            'Connection failed: $e',
            style: GoogleFonts.outfit(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTestingConnection = false);
      }
    }
  }

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
        title: Text('Settings',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Notifications ──
          _sectionLabel('Notifications'),
          const SizedBox(height: 10),
          _buildCard([
            _buildToggle(
              icon: Icons.notifications_active_outlined,
              color: const Color(0xFFF0A500),
              title: 'Push Notifications',
              subtitle: 'Receive all app notifications',
              value: _pushNotifications,
              onChanged: (v) {
                setState(() => _pushNotifications = v);
                _setPref('pref_push', v);
              },
            ),
            const Divider(height: 1, indent: 70),
            _buildToggle(
              icon: Icons.local_shipping_outlined,
              color: AppTheme.primaryGreen,
              title: 'Order Updates',
              subtitle: 'Shipping & delivery alerts',
              value: _orderUpdates,
              onChanged: (v) {
                setState(() => _orderUpdates = v);
                _setPref('pref_orders', v);
              },
            ),
            const Divider(height: 1, indent: 70),
            _buildToggle(
              icon: Icons.water_drop_outlined,
              color: const Color(0xFF2196F3),
              title: 'Watering Reminders',
              subtitle: 'Plant care alerts',
              value: _reminderAlerts,
              onChanged: (v) {
                setState(() => _reminderAlerts = v);
                _setPref('pref_reminders', v);
              },
            ),
            const Divider(height: 1, indent: 70),
            _buildToggle(
              icon: Icons.local_offer_outlined,
              color: const Color(0xFFE91E63),
              title: 'Promotions & Offers',
              subtitle: 'Deals and special offers',
              value: _promoEmails,
              onChanged: (v) {
                setState(() => _promoEmails = v);
                _setPref('pref_promo', v);
              },
            ),
          ]),

          const SizedBox(height: 20),

          // ── Language ──
          _sectionLabel('Language & Region'),
          const SizedBox(height: 10),
          _buildCard([
            _buildChevronTile(
              icon: Icons.language_rounded,
              color: const Color(0xFF9C27B0),
              title: 'App Language',
              trailing: Text(_language,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF878787))),
              onTap: () => _showLanguagePicker(),
            ),
          ]),

          const SizedBox(height: 20),

          // â”€â”€ Debug â”€â”€
          _sectionLabel('Debug'),
          const SizedBox(height: 10),
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'API Host',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1111),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _apiHostController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {
                    _validationError = _validateHostInput(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: '10.0.2.2',
                  helperText: _validationError != null
                      ? null
                      : 'Android emulator uses 10.0.2.2; physical devices need your PC IP.',
                  helperMaxLines: 2,
                  errorText: _validationError,
                  errorStyle: GoogleFonts.outfit(color: Colors.red.shade400),
                  suffixIcon: _apiHostController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () async {
                            await ApiConfigService.clearApiHost();
                            if (!mounted) return;
                            setState(() {
                              _apiHost = '';
                              _apiHostController.clear();
                              _validationError = null;
                            });
                            _checkConnectionSilently();
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validationError != null
                          ? null
                          : () async {
                              final value = _apiHostController.text;
                              final messenger = ScaffoldMessenger.of(context);
                              await ApiConfigService.setApiHost(value);
                              if (!mounted) return;
                              setState(() {
                                _apiHost = value.trim();
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value.trim().isEmpty
                                        ? 'API host reset to default.'
                                        : 'API host saved: ${value.trim()}',
                                    style: GoogleFonts.outfit(),
                                  ),
                                ),
                              );
                              _checkConnectionSilently();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Host',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ApiConfigService.clearApiHost();
                      if (!mounted) return;
                      setState(() {
                        _apiHost = '';
                        _apiHostController.clear();
                        _validationError = null;
                      });
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'API host reset to default.',
                            style: GoogleFonts.outfit(),
                          ),
                        ),
                      );
                      _checkConnectionSilently();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.oliveGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      side: BorderSide(color: AppTheme.oliveGreen.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    side: BorderSide(
                      color: AppTheme.primaryGreen.withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isTestingConnection
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering_rounded),
                  label: Text(
                    _isTestingConnection ? 'Testing...' : 'Test Connection',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Current API base: ${AppConfig.flaskBaseUrl}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFF878787),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Privacy ──
          _sectionLabel('Privacy & Data'),
          const SizedBox(height: 10),
          _buildCard([
            _buildChevronTile(
              icon: Icons.privacy_tip_outlined,
              color: const Color(0xFF607D8B),
              title: 'Privacy Policy',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 70),
            _buildChevronTile(
              icon: Icons.description_outlined,
              color: const Color(0xFF607D8B),
              title: 'Terms of Service',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 70),
            _buildChevronTile(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              title: 'Delete Account',
              titleColor: Colors.red,
              onTap: () => _confirmDeleteAccount(context),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────

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

  Widget _buildToggle({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F1111))),
        subtitle: Text(subtitle,
            style: GoogleFonts.outfit(
                fontSize: 12, color: const Color(0xFF878787))),
        activeColor: AppTheme.primaryGreen,
        value: value,
        onChanged: onChanged,
      );

  Widget _buildChevronTile({
    required IconData icon,
    required Color color,
    required String title,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    child: Text(title,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: titleColor ??
                                const Color(0xFF0F1111)))),
                trailing ??
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFFBDBDBD), size: 22),
              ],
            ),
          ),
        ),
      );

  void _showLanguagePicker() {
    showModalBottomSheet(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['English', 'العربية'].map((lang) => RadioListTile<String>(
                  title: Text(lang, style: GoogleFonts.outfit()),
                  value: lang,
                  groupValue: _language,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _language = val);
                      _setLang(val);
                      Navigator.pop(ctx);
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text(
          'This action is permanent and cannot be undone. '
          'All your data including orders and plants will be deleted.',
          style: GoogleFonts.outfit(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: const Color(0xFF565959))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Delete',
                style: GoogleFonts.outfit(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
