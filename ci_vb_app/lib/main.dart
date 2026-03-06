// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/data_repository.dart';
import 'providers/app_providers.dart';
import 'screens/calculator_screen.dart';
import 'screens/materials_screen.dart';
import 'screens/costs_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataRepository().init();
  runApp(const ProviderScope(child: VacuumBagsApp()));
}

class VacuumBagsApp extends ConsumerWidget {
  const VacuumBagsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    return MaterialApp(
      title: 'Ci™ Metering | Vacuum Bags SARL',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.calculate_outlined, activeIcon: Icons.calculate, label: 'Calculator'),
    (icon: Icons.layers_outlined, activeIcon: Icons.layers, label: 'Materials'),
    (icon: Icons.attach_money_outlined, activeIcon: Icons.attach_money, label: 'Costs'),
    (icon: Icons.work_outline, activeIcon: Icons.work, label: 'Jobs'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  static const _screens = <Widget>[
    CalculatorScreen(),
    MaterialsScreen(),
    CostsScreen(),
    JobsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
