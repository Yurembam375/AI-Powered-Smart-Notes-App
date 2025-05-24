import 'package:ai_smart_app/provide/theme_provider.dart';
import 'package:ai_smart_app/screen/editor_screen.dart';
import 'package:ai_smart_app/screen/view_notes_screen.dart';
import 'package:ai_smart_app/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Notes')),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(child: Text('Settings')),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final isDark = themeProvider.currentTheme == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomActionButton(
              label: 'Add Note',
              icon: Icons.add,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomActionButton(
              label: 'View Notes',
              icon: Icons.notes,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ViewNotesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
