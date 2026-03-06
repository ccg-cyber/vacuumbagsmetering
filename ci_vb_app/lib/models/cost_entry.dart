// lib/models/cost_entry.dart
import 'package:hive/hive.dart';

part 'cost_entry.g.dart';

@HiveType(typeId: 1)
class CostEntry extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double cost;

  CostEntry({required this.name, required this.cost});

  factory CostEntry.fromJson(Map<String, dynamic> j) => CostEntry(
        name: j['name'] as String,
        cost: (j['cost'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'cost': cost};
}
