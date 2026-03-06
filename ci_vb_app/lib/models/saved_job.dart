// lib/models/saved_job.dart
import 'package:hive/hive.dart';

part 'saved_job.g.dart';

@HiveType(typeId: 2)
class SavedJob extends HiveObject {
  @HiveField(0)
  String jobName;

  @HiveField(1)
  String? customerName;

  @HiveField(2)
  String? itemCode;

  @HiveField(3)
  String? note;

  @HiveField(4)
  String productType;

  @HiveField(5)
  double l;

  @HiveField(6)
  double w;

  @HiveField(7)
  double g;

  @HiveField(8)
  double qty;

  @HiveField(9)
  int numLayers;

  @HiveField(10)
  String layer1;

  @HiveField(11)
  String layer2;

  @HiveField(12)
  String layer3;

  @HiveField(13)
  String layer4;

  @HiveField(14)
  DateTime createdAt;

  // Cached results (serialized as JSON-ish doubles)
  @HiveField(15)
  double? weightKg1;
  @HiveField(16)
  double? weightKg2;
  @HiveField(17)
  double? weightKg3;
  @HiveField(18)
  double? weightKg4;

  SavedJob({
    required this.jobName,
    this.customerName,
    this.itemCode,
    this.note,
    required this.productType,
    required this.l,
    required this.w,
    required this.g,
    required this.qty,
    required this.numLayers,
    required this.layer1,
    required this.layer2,
    required this.layer3,
    required this.layer4,
    required this.createdAt,
    this.weightKg1,
    this.weightKg2,
    this.weightKg3,
    this.weightKg4,
  });

  SavedJob copyWith({
    String? jobName,
    String? customerName,
    String? itemCode,
    String? note,
    String? productType,
    double? l,
    double? w,
    double? g,
    double? qty,
    int? numLayers,
    String? layer1,
    String? layer2,
    String? layer3,
    String? layer4,
  }) =>
      SavedJob(
        jobName: jobName ?? this.jobName,
        customerName: customerName ?? this.customerName,
        itemCode: itemCode ?? this.itemCode,
        note: note ?? this.note,
        productType: productType ?? this.productType,
        l: l ?? this.l,
        w: w ?? this.w,
        g: g ?? this.g,
        qty: qty ?? this.qty,
        numLayers: numLayers ?? this.numLayers,
        layer1: layer1 ?? this.layer1,
        layer2: layer2 ?? this.layer2,
        layer3: layer3 ?? this.layer3,
        layer4: layer4 ?? this.layer4,
        createdAt: DateTime.now(),
        weightKg1: weightKg1,
        weightKg2: weightKg2,
        weightKg3: weightKg3,
        weightKg4: weightKg4,
      );
}
