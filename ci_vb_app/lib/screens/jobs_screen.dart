// lib/screens/jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/saved_job.dart';

final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(savedJobsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text('No saved jobs yet.',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 6),
                  Text('Calculate a job and tap Save.',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _JobCard(job: jobs[i], index: i),
            ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  final SavedJob job;
  final int index;
  const _JobCard({required this.job, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(job.jobName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Load into Calculator',
                  onTap: () {
                    ref.read(calcStateProvider.notifier).loadFromJob(job);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Loaded: ${job.jobName}')));
                  },
                ),
                _ActionButton(
                  icon: Icons.copy_outlined,
                  tooltip: 'Duplicate',
                  onTap: () => ref.read(savedJobsProvider.notifier).duplicate(job),
                ),
                _ActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  tooltip: 'Export PDF',
                  onTap: () async {
                    try {
                      await ref.read(exportProvider).exportToPdf(job);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')));
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.table_chart_outlined,
                  tooltip: 'Export CSV',
                  onTap: () async {
                    try {
                      await ref.read(exportProvider).exportToCsv(job);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')));
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: cs.error,
                  onTap: () => ref.read(savedJobsProvider.notifier).delete(index),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (job.customerName != null)
              _InfoChip(Icons.person_outline, job.customerName!),
            if (job.itemCode != null) _InfoChip(Icons.tag, job.itemCode!),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _Tag(job.productType, cs.primary),
                _Tag('${job.numLayers}L', cs.secondary),
                _Tag('${job.l}×${job.w}×${job.g}cm', cs.tertiary),
                _Tag('${job.qty.toStringAsFixed(0)} pcs', cs.outline),
              ],
            ),
            const SizedBox(height: 6),
            // Weight summary
            if (job.weightKg1 != null)
              Row(
                children: [
                  Text('W/KG: ',
                      style: theme.textTheme.labelSmall),
                  if (job.weightKg1 != null) Text('1L: ${job.weightKg1!.toStringAsFixed(2)}  '),
                  if (job.weightKg2 != null) Text('2L: ${job.weightKg2!.toStringAsFixed(2)}  '),
                  if (job.weightKg3 != null) Text('3L: ${job.weightKg3!.toStringAsFixed(2)}  '),
                  if (job.weightKg4 != null) Text('4L: ${job.weightKg4!.toStringAsFixed(2)}'),
                ],
              ),
            const SizedBox(height: 4),
            Text(_dateFmt.format(job.createdAt),
                style:
                    theme.textTheme.labelSmall?.copyWith(color: cs.outline)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  const _ActionButton(
      {required this.icon,
      required this.tooltip,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 18, color: color),
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(4),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 3),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline)),
        ],
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}
