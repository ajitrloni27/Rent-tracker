import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (val) {
              ref.read(darkModeProvider.notifier).toggle();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export to PDF'),
            onTap: () async {
              final transactions = transactionsAsync.value ?? [];
              if (transactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export')),
                );
                return;
              }
              await ExportService.exportPDF(transactions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export to CSV'),
            onTap: () async {
              final transactions = transactionsAsync.value ?? [];
              if (transactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export')),
                );
                return;
              }
              await ExportService.exportCSV(transactions);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Backup Database'),
            onTap: () async {
              final success = await ExportService.backupDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Backup saved' : 'Backup failed/cancelled')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Database'),
            onTap: () async {
              final success = await ExportService.restoreDatabase();
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database restored. Please restart app.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore failed/cancelled')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete All Data'),
                  content: const Text('Are you sure you want to delete all transactions? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(transactionRepositoryProvider).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data deleted')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
