import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/db_service.dart';
import 'onboarding.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Easier on the eyes at night'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Preferences'),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            subtitle: const Text('Choose your currency symbol'),
            trailing: DropdownButton<String>(
              value: 'INR', // TODO: Fetch from user service
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'INR', child: Text('Rupee (₹)')),
                DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
              ],
              onChanged: (value) {
                // TODO: Update user service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency update coming soon!')),
                );
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Update your limit lock PIN'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change coming in next update!')),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Copy your data to clipboard'),
            onTap: () async {
              final backupService = BackupService();
              final json = await backupService.exportData();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Export Data'),
                    content: SelectableText(json),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from JSON'),
            onTap: () {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Import Data'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Paste JSON here',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final backupService = BackupService();
                          await backupService.importData(controller.text);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data restored! Please restart app.')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset App Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Clear all data and restart onboarding'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset App?'),
                  content: const Text('This will delete ALL data. This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final dbService = DatabaseService();
                        await dbService.resetDatabase();
                        
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
