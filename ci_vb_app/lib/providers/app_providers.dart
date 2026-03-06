// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/material_entry.dart';
import '../models/cost_entry.dart';
import '../models/saved_job.dart';
import '../services/calculator_engine.dart';
import '../services/data_repository.dart';
import '../services/export_service.dart';

// ---- Repository ----
final repositoryProvider = Provider<DataRepository>((ref) => DataRepository());

// ---- Materials ----
final materialsProvider = StateNotifierProvider<MaterialsNotifier, List<MaterialEntry>>(
  (ref) => MaterialsNotifier(ref.watch(repositoryProvider)),
);

class MaterialsNotifier extends StateNotifier<List<MaterialEntry>> {
  final DataRepository _repo;
  MaterialsNotifier(this._repo) : super(_repo.getMaterials());

  void refresh() => state = _repo.getMaterials();
  Future<void> add(MaterialEntry m) async {
    await _repo.addMaterial(m);
    refresh();
  }
  Future<void> delete(int index) async {
    await _repo.deleteMaterial(index);
    refresh();
  }
}

// ---- Costs ----
final costsProvider = StateNotifierProvider<CostsNotifier, List<CostEntry>>(
  (ref) => CostsNotifier(ref.watch(repositoryProvider)),
);

class CostsNotifier extends StateNotifier<List<CostEntry>> {
  final DataRepository _repo;
  CostsNotifier(this._repo) : super(_repo.getCosts());

  void refresh() => state = _repo.getCosts();
  Future<void> add(CostEntry c) async {
    await _repo.addCost(c);
    refresh();
  }
  Future<void> delete(int index) async {
    await _repo.deleteCost(index);
    refresh();
  }
}

// ---- Engine ----
final engineProvider = Provider<CalculatorEngine>((ref) {
  final materials = ref.watch(materialsProvider);
  final costs = ref.watch(costsProvider);
  return CalculatorEngine(materials: materials, costs: costs);
});

// ---- Calculator State ----
class CalcState {
  final ProductType product;
  final double l;
  final double w;
  final double g;
  final double qty;
  final int numLayers;
  final List<String> layers; // always 4 elements
  final String? customerName;
  final String? itemCode;
  final String? note;

  const CalcState({
    this.product = ProductType.zipperBag,
    this.l = 30,
    this.w = 25,
    this.g = 8,
    this.qty = 1000,
    this.numLayers = 2,
    required this.layers,
    this.customerName,
    this.itemCode,
    this.note,
  });

  CalcState copyWith({
    ProductType? product,
    double? l,
    double? w,
    double? g,
    double? qty,
    int? numLayers,
    List<String>? layers,
    String? customerName,
    String? itemCode,
    String? note,
  }) =>
      CalcState(
        product: product ?? this.product,
        l: l ?? this.l,
        w: w ?? this.w,
        g: g ?? this.g,
        qty: qty ?? this.qty,
        numLayers: numLayers ?? this.numLayers,
        layers: layers ?? this.layers,
        customerName: customerName ?? this.customerName,
        itemCode: itemCode ?? this.itemCode,
        note: note ?? this.note,
      );
}

final calcStateProvider = StateNotifierProvider<CalcNotifier, CalcState>((ref) {
  final mats = ref.watch(materialsProvider);
  final defaultLayer = mats.isNotEmpty ? mats.first.name : 'PE 70';
  return CalcNotifier(CalcState(
    layers: [defaultLayer, defaultLayer, defaultLayer, defaultLayer],
  ));
});

class CalcNotifier extends StateNotifier<CalcState> {
  CalcNotifier(super.state);

  void setProduct(ProductType p) => state = state.copyWith(product: p);
  void setL(double v) => state = state.copyWith(l: v);
  void setW(double v) => state = state.copyWith(w: v);
  void setG(double v) => state = state.copyWith(g: v);
  void setQty(double v) => state = state.copyWith(qty: v);
  void setNumLayers(int v) => state = state.copyWith(numLayers: v);
  void setLayer(int index, String name) {
    final newLayers = List<String>.from(state.layers);
    newLayers[index] = name;
    state = state.copyWith(layers: newLayers);
  }
  void setCustomer(String? v) => state = state.copyWith(customerName: v);
  void setItemCode(String? v) => state = state.copyWith(itemCode: v);
  void setNote(String? v) => state = state.copyWith(note: v);
  void loadFromJob(SavedJob job) {
    state = CalcState(
      product: ProductType.values.firstWhere(
        (p) => p.displayName == job.productType,
        orElse: () => ProductType.zipperBag,
      ),
      l: job.l,
      w: job.w,
      g: job.g,
      qty: job.qty,
      numLayers: job.numLayers,
      layers: [job.layer1, job.layer2, job.layer3, job.layer4],
      customerName: job.customerName,
      itemCode: job.itemCode,
      note: job.note,
    );
  }
}

// ---- Computed result ----
final meteringResultProvider = Provider<MeteringResult?>((ref) {
  final state = ref.watch(calcStateProvider);
  final engine = ref.watch(engineProvider);
  try {
    return engine.calculate(
      product: state.product,
      l: state.l,
      w: state.w,
      g: state.g,
      qty: state.qty,
      numLayers: state.numLayers,
      layers: state.layers,
    );
  } catch (_) {
    return null;
  }
});

// ---- Saved Jobs ----
final savedJobsProvider = StateNotifierProvider<JobsNotifier, List<SavedJob>>(
  (ref) => JobsNotifier(ref.watch(repositoryProvider)),
);

class JobsNotifier extends StateNotifier<List<SavedJob>> {
  final DataRepository _repo;
  JobsNotifier(this._repo) : super(_repo.getJobs());

  void refresh() => state = _repo.getJobs();
  Future<void> save(SavedJob job) async {
    await _repo.saveJob(job);
    refresh();
  }
  Future<void> delete(int index) async {
    await _repo.deleteJob(index);
    refresh();
  }
  Future<void> duplicate(SavedJob job) async {
    await _repo.duplicateJob(job);
    refresh();
  }
}

// ---- Export ----
final exportProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(engineProvider));
});

// ---- Dark mode ----
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref.watch(repositoryProvider));
});

class DarkModeNotifier extends StateNotifier<bool> {
  final DataRepository _repo;
  DarkModeNotifier(this._repo) : super(_repo.darkMode);
  Future<void> toggle() async {
    state = !state;
    await _repo.setDarkMode(state);
  }
}
