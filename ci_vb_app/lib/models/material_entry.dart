// lib/models/material_entry.dart
import 'package:hive/hive.dart';

part 'material_entry.g.dart';

@HiveType(typeId: 0)
class MaterialEntry extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double? colB;

  @HiveField(2)
  final double? gM2;

  @HiveField(3)
  final double? thicknessUm;

  @HiveField(4)
  final double? colE;

  @HiveField(5)
  final double? colF;

  /// weight_factor = Sheet2 column G — used in VLOOKUP(name, Sheet2!A:G, 7)
  /// This is: thickness_um * density / 1_000_000  (g per cm² per cm length)
  @HiveField(6)
  final double? weightFactor;

  MaterialEntry({
    required this.name,
    this.colB,
    this.gM2,
    this.thicknessUm,
    this.colE,
    this.colF,
    this.weightFactor,
  });

  factory MaterialEntry.fromJson(Map<String, dynamic> j) => MaterialEntry(
        name: j['name'] as String,
        colB: (j['col_b'] as num?)?.toDouble(),
        gM2: (j['g_m2'] as num?)?.toDouble(),
        thicknessUm: (j['thickness_um'] as num?)?.toDouble(),
        colE: (j['col_e'] as num?)?.toDouble(),
        colF: (j['col_f'] as num?)?.toDouble(),
        weightFactor: (j['weight_factor'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'col_b': colB,
        'g_m2': gM2,
        'thickness_um': thicknessUm,
        'col_e': colE,
        'col_f': colF,
        'weight_factor': weightFactor,
      };
}
