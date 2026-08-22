import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value.trim());
  }

  Future<void> _resetApp() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('Are you sure you want to reset all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm1 == true) {
      if (!mounted) return;
      final confirm2 = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Final Warning'),
          content: const Text('Are you ABSOLUTELY sure? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Reset Everything', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm2 == true) {
        await ref.read(transactionProvider.notifier).clearAll();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App data has been reset.')),
        );
      }
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Profile'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: _saveName,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Preferences'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  subtitle: const Text('Rent & Expense Tracker v1.0.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Rent & Expense Tracker',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Download Monthly Report'),
                  subtitle: const Text('Export this month\'s transactions'),
                  onTap: () async {
                    final transactions = ref.read(transactionProvider);
                    final now = DateTime.now();
                    final currentMonthTransactions = transactions.where((t) {
                      return t.date.year == now.year && t.date.month == now.month;
                    }).toList();

                    if (currentMonthTransactions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No transactions for this month to export.')),
                      );
                      return;
                    }
                    
                    ExportService.exportPDF(currentMonthTransactions);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Danger Zone', color: Colors.red),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset App Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Clear all transactions and data'),
                  onTap: _resetApp,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: color ?? Colors.grey.shade600,
        ),
      ),
    );
  }
}
