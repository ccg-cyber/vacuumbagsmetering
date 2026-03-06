// lib/widgets/result_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/calculator_engine.dart';
import '../theme.dart';

final _fmt = NumberFormat('#,##0.000');
final _fmt2 = NumberFormat('#,##0.00');

class ResultCard extends StatelessWidget {
  final String title;
  final LayerResult result;
  final bool isRoll;

  const ResultCard({
    super.key,
    required this.title,
    required this.result,
    this.isRoll = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Main metrics row
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'WEIGHT / KG',
                    value: _fmt.format(result.weightKg),
                    unit: 'kg',
                    color: kBrandBlue,
                  ),
                ),
                if (!isRoll) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'WEIGHT / UNIT',
                      value: _fmt.format(result.weightUnitGr),
                      unit: 'gr',
                      color: kBrandCyan,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'METERS / QTY',
                    value: _fmt2.format(result.metersQty),
                    unit: 'm',
                    color: kResultGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: 'METERS / KG',
                    value: _fmt2.format(result.metersKg),
                    unit: 'm/kg',
                    color: kResultOrange,
                  ),
                ),
              ],
            ),
            // Layer breakdown
            if (result.layerWeightsKg.length > 1) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text('Layer Weight Breakdown',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 4),
              for (int i = 0; i < result.layerWeightsKg.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      _LayerDot(i),
                      const SizedBox(width: 6),
                      Text('Layer ${i + 1}:',
                          style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(
                        '${_fmt.format(result.layerWeightsKg[i])} kg',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit,
                    style: TextStyle(
                        fontSize: 11,
                        color: color.withOpacity(0.7))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayerDot extends StatelessWidget {
  final int index;
  static const colors = [kBrandBlue, kBrandCyan, kResultGreen, kResultOrange];
  const _LayerDot(this.index);

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors[index % colors.length],
        ),
      );
}
