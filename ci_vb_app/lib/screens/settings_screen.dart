// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_providers.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ---- App branding header ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kBrandDark,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 32, color: Colors.white),
                      Text('Ci™',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Vacuum Bags SARL',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Ci™ Metering Support v2.1',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Premium factory-side packaging calculator',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.outline)),
              ],
            ),
          ),
          const Divider(),

          // ---- Website links ----
          ListTile(
            leading: Icon(Icons.language, color: cs.primary),
            title: const Text('vacuumbags.com.lb'),
            subtitle: const Text('Official Vacuum Bags website'),
            onTap: () => _launchUrl('https://vacuumbags.com.lb'),
          ),
          const Divider(),

          // ---- Settings ----
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: darkMode,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Reload original material & cost data'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),

          // ---- Formula reference ----
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Formula Reference', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                _FormulaRow('Zipper / Slider Bag',
                    'WU = (L×2+G)×W×ΣK + 0.08×W'),
                _FormulaRow('Doypack Bag', 'WU = (L×2+G)×W×ΣK'),
                _FormulaRow('C.S. Bag', 'WU = ((W+G)×2+3)×L×ΣK'),
                _FormulaRow('Quattro Bag', 'WU = (W+G)×2×L×ΣK'),
                _FormulaRow('Side Seal Bag', 'WU = ((W+G)×2+1.5)×L×ΣK'),
                _FormulaRow('Label / Sleeve', 'WU = (W×2+1)×L×ΣK'),
                _FormulaRow('S.W. / T.S.S. Bag', 'WU = (L×2+G)×W×ΣK'),
                _FormulaRow('ROLL', 'Len = WeightKG×1000/(ΣK×Width×100)'),
                SizedBox(height: 6),
                Text(
                  'WU = Weight per Unit (gr), K = weight factor from Sheet2 col G\n'
                  'WEIGHT/KG = qty×(WU−bonus)/1000\n'
                  'METERS/KG = WEIGHT/KG×1000/(perimeter×ΣK×100)',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const Divider(),

          // ---- CCG Credit / About ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kBrandDark,
                        kBrandDark.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text('Powered by',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      const Text('CCG',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 2),
                      const Text('Cyber Consulting Group',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl('https://ccg.support'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('ccg.support',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '© ${DateTime.now().year} Vacuum Bags SARL. All rights reserved.\n'
                  'Ci™ is a trademark of Vacuum Bags SARL.\n'
                  'Developed by CCG — ccg.support',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.outline, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data?'),
        content: const Text(
            'This will reload the original materials and costs from the built-in seed files. Custom entries will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await ref.read(repositoryProvider).resetToDefaults();
              ref.read(materialsProvider.notifier).refresh();
              ref.read(costsProvider.notifier).refresh();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Data reset!')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final String product;
  final String formula;
  const _FormulaRow(this.product, this.formula);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text(product,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(
              child: Text(formula,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'monospace')),
            ),
          ],
        ),
      );
}
