// lib/screens/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../services/calculator_engine.dart';
import '../models/saved_job.dart';
import '../widgets/result_card.dart';
import '../widgets/dim_field.dart';
import '../widgets/layer_selector.dart';

final _fmt = NumberFormat('#,##0.00');

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calcStateProvider);
    final notifier = ref.read(calcStateProvider.notifier);
    final result = ref.watch(meteringResultProvider);
    final materials = ref.watch(materialsProvider);
    final matNames = materials.map((m) => m.name).toList();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  const Text('Ci™',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                  const SizedBox(width: 6),
                  Text('Metering Calculator',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save Job',
                onPressed: () => _showSaveDialog(context, ref, state),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Job info (optional) ----
                  _SectionHeader(label: 'Job Info (optional)'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                          child: DimField(
                              label: 'Customer',
                              isText: true,
                              initialValue: state.customerName ?? '',
                              onChanged: (v) => notifier.setCustomer(v.isEmpty ? null : v))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: DimField(
                              label: 'Item Code',
                              isText: true,
                              initialValue: state.itemCode ?? '',
                              onChanged: (v) => notifier.setItemCode(v.isEmpty ? null : v))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ---- Product ----
                  _SectionHeader(label: 'Product'),
                  const SizedBox(height: 6),
                  _ProductDropdown(
                    value: state.product,
                    onChanged: notifier.setProduct,
                  ),
                  const SizedBox(height: 12),

                  // ---- Dimensions ----
                  _SectionHeader(label: 'Dimensions & Quantity'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                          child: DimField(
                              label: state.product == ProductType.roll ? 'Weight (kg)' : 'L (cm)',
                              initialValue: state.l.toString(),
                              onChanged: (v) => notifier.setL(double.tryParse(v) ?? state.l))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DimField(
                              label: 'W (cm)',
                              initialValue: state.w.toString(),
                              onChanged: (v) => notifier.setW(double.tryParse(v) ?? state.w))),
                      if (state.product.hasGusset) ...[
                        const SizedBox(width: 8),
                        Expanded(
                            child: DimField(
                                label: 'G (cm)',
                                initialValue: state.g.toString(),
                                onChanged: (v) => notifier.setG(double.tryParse(v) ?? state.g))),
                      ],
                    ],
                  ),
                  if (state.product.hasQty) ...[
                    const SizedBox(height: 8),
                    DimField(
                        label: 'Qty / pcs',
                        initialValue: state.qty.toStringAsFixed(0),
                        onChanged: (v) => notifier.setQty(double.tryParse(v) ?? state.qty)),
                  ],
                  const SizedBox(height: 12),

                  // ---- Layers ----
                  _SectionHeader(label: 'Layer Structure'),
                  const SizedBox(height: 6),
                  _NumLayersPicker(
                    value: state.numLayers,
                    onChanged: notifier.setNumLayers,
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < state.numLayers; i++) ...[
                    LayerSelector(
                      layerIndex: i,
                      selected: state.layers[i],
                      materialNames: matNames,
                      onChanged: (name) => notifier.setLayer(i, name),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // ---- Note ----
                  const SizedBox(height: 8),
                  DimField(
                      label: 'Note (optional)',
                      isText: true,
                      initialValue: state.note ?? '',
                      onChanged: (v) => notifier.setNote(v.isEmpty ? null : v)),

                  const SizedBox(height: 20),

                  // ---- RESULTS ----
                  if (result != null) ...[
                    _SectionHeader(label: 'Results'),
                    const SizedBox(height: 8),
                    if (state.product == ProductType.roll)
                      _RollResults(result: result, state: state)
                    else
                      _BagResults(result: result, state: state),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref, CalcState state) {
    final ctrl = TextEditingController(
        text: '${state.product.displayName} - ${DateTime.now().day}/${DateTime.now().month}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Job'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Job name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final result = ref.read(meteringResultProvider);
              final job = SavedJob(
                jobName: ctrl.text.trim().isEmpty ? 'Job' : ctrl.text.trim(),
                customerName: state.customerName,
                itemCode: state.itemCode,
                note: state.note,
                productType: state.product.displayName,
                l: state.l,
                w: state.w,
                g: state.g,
                qty: state.qty,
                numLayers: state.numLayers,
                layer1: state.layers[0],
                layer2: state.layers[1],
                layer3: state.layers[2],
                layer4: state.layers[3],
                createdAt: DateTime.now(),
                weightKg1: result?.layer1Result?.weightKg,
                weightKg2: result?.layer2Result?.weightKg,
                weightKg3: result?.layer3Result?.weightKg,
                weightKg4: result?.layer4Result?.weightKg,
              );
              ref.read(savedJobsProvider.notifier).save(job);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job saved!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _BagResults extends StatelessWidget {
  final MeteringResult result;
  final CalcState state;
  const _BagResults({required this.result, required this.state});

  @override
  Widget build(BuildContext context) {
    final structs = <(String, LayerResult?)>[];
    if (result.layer1Result != null)
      structs.add(('1 Layer\n${state.layers[0]}', result.layer1Result));
    if (result.layer2Result != null && state.numLayers >= 2)
      structs.add(('2 Layers\n${state.layers[0]} / ${state.layers[1]}', result.layer2Result));
    if (result.layer3Result != null && state.numLayers >= 3)
      structs.add(('3 Layers\n…/${state.layers[2]}', result.layer3Result));
    if (result.layer4Result != null && state.numLayers >= 4)
      structs.add(('4 Layers\n…/${state.layers[3]}', result.layer4Result));

    return Column(
      children: structs
          .map((s) => ResultCard(title: s.$1, result: s.$2!))
          .toList(),
    );
  }
}

class _RollResults extends StatelessWidget {
  final MeteringResult result;
  final CalcState state;
  const _RollResults({required this.result, required this.state});

  @override
  Widget build(BuildContext context) {
    final structs = <(String, LayerResult?)>[];
    if (result.layer1Result != null)
      structs.add(('1 Layer — ${state.layers[0]}', result.layer1Result));
    if (result.layer2Result != null && state.numLayers >= 2)
      structs.add(('2 Layers', result.layer2Result));
    if (result.layer3Result != null && state.numLayers >= 3)
      structs.add(('3 Layers', result.layer3Result));
    if (result.layer4Result != null && state.numLayers >= 4)
      structs.add(('4 Layers', result.layer4Result));

    return Column(
      children: structs.map((s) => ResultCard(title: s.$1, result: s.$2!, isRoll: true)).toList(),
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  final ProductType value;
  final ValueChanged<ProductType> onChanged;
  const _ProductDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductType>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Product Type'),
      items: ProductType.values
          .map((p) => DropdownMenuItem(value: p, child: Text(p.displayName)))
          .toList(),
      onChanged: (p) => p != null ? onChanged(p) : null,
    );
  }
}

class _NumLayersPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _NumLayersPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [1, 2, 3, 4].map((n) {
        final selected = n == value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$n Layer${n > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
