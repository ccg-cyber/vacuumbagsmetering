// lib/widgets/layer_selector.dart
import 'package:flutter/material.dart';
import '../theme.dart';

const _layerColors = [kBrandBlue, kBrandCyan, kResultGreen, kResultOrange];

class LayerSelector extends StatelessWidget {
  final int layerIndex;
  final String selected;
  final List<String> materialNames;
  final ValueChanged<String> onChanged;

  const LayerSelector({
    super.key,
    required this.layerIndex,
    required this.selected,
    required this.materialNames,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = _layerColors[layerIndex % _layerColors.length];
    final effectiveSelected =
        materialNames.contains(selected) ? selected : (materialNames.isNotEmpty ? materialNames.first : '');
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'L${layerIndex + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: effectiveSelected.isEmpty ? null : effectiveSelected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Layer ${layerIndex + 1} Material',
              labelStyle: TextStyle(color: color),
            ),
            items: materialNames
                .map((n) => DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ),
      ],
    );
  }
}
