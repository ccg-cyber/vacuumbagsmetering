// lib/services/data_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/material_entry.dart';
import '../models/cost_entry.dart';
import '../models/saved_job.dart';
import 'calculator_engine.dart';

class DataRepository {
  static const _materialBoxName = 'materials';
  static const _costBoxName = 'costs';
  static const _jobBoxName = 'saved_jobs';
  static const _seedKey = 'seeded_v2';

  late Box<MaterialEntry> _materialBox;
  late Box<CostEntry> _costBox;
  late Box<SavedJob> _jobBox;
  late Box<dynamic> _settingsBox;

  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MaterialEntryAdapter());
    Hive.registerAdapter(CostEntryAdapter());
    Hive.registerAdapter(SavedJobAdapter());

    _materialBox = await Hive.openBox<MaterialEntry>(_materialBoxName);
    _costBox = await Hive.openBox<CostEntry>(_costBoxName);
    _jobBox = await Hive.openBox<SavedJob>(_jobBoxName);
    _settingsBox = await Hive.openBox('settings');

    await _seedIfNeeded();
  }

  Future<void> _seedIfNeeded() async {
    if (_settingsBox.get(_seedKey) == true) return;

    // Load materials
    final matJson = await rootBundle.loadString('assets/materials.json');
    final matList = (jsonDecode(matJson) as List)
        .map((e) => MaterialEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    await _materialBox.clear();
    await _materialBox.addAll(matList);

    // Load costs
    final costJson = await rootBundle.loadString('assets/costs.json');
    final costList = (jsonDecode(costJson) as List)
        .map((e) => CostEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    await _costBox.clear();
    await _costBox.addAll(costList);

    await _settingsBox.put(_seedKey, true);
  }

  List<MaterialEntry> getMaterials() => _materialBox.values.toList();
  List<CostEntry> getCosts() => _costBox.values.toList();

  CalculatorEngine buildEngine() => CalculatorEngine(
        materials: getMaterials(),
        costs: getCosts(),
      );

  // ---- Material CRUD ----
  Future<void> addMaterial(MaterialEntry m) => _materialBox.add(m);
  Future<void> updateMaterial(int index, MaterialEntry m) =>
      _materialBox.putAt(index, m);
  Future<void> deleteMaterial(int index) => _materialBox.deleteAt(index);

  // ---- Cost CRUD ----
  Future<void> addCost(CostEntry c) => _costBox.add(c);
  Future<void> updateCost(int index, CostEntry c) => _costBox.putAt(index, c);
  Future<void> deleteCost(int index) => _costBox.deleteAt(index);

  // ---- Job CRUD ----
  List<SavedJob> getJobs() {
    final jobs = _jobBox.values.toList();
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs;
  }

  Future<void> saveJob(SavedJob job) => _jobBox.add(job);

  Future<void> deleteJob(int index) => _jobBox.deleteAt(index);

  Future<void> duplicateJob(SavedJob job) {
    final copy = job.copyWith(jobName: '${job.jobName} (copy)');
    return _jobBox.add(copy);
  }

  // ---- Settings ----
  bool get darkMode => _settingsBox.get('darkMode', defaultValue: false);
  Future<void> setDarkMode(bool v) => _settingsBox.put('darkMode', v);

  Future<void> resetToDefaults() async {
    await _settingsBox.delete(_seedKey);
    await _materialBox.clear();
    await _costBox.clear();
    await _seedIfNeeded();
  }
}
