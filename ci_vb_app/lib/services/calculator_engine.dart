// lib/services/calculator_engine.dart
//
// ============================================================
// METERING CALCULATOR ENGINE — Vacuum Bags SARL
// ============================================================
// Formula mapping from Metering_support_2_1.xlsx Sheet1
//
// Variable naming matches the Excel layout:
//   L  = B column  (length, cm)
//   W  = C column  (width, cm)
//   G  = D column  (gusset, cm)
//   qty = E column (pieces)
//   k1..k4 = weight factor per layer (VLOOKUP → Sheet2 col G)
//
// Each product type uses a different "perimeter" calculation.
//
// WEIGHT/UNIT (grams) per layer structure:
//   weightUnit_N = perimeter(product) * sumOf(k1..kN)    [+ zipper bonus for zippers]
//
// WEIGHT/KG = qty * weightUnit / 1000
//
// METERS/QTY = depends on product orientation (L or W based)
// METERS/KG  = WEIGHT/KG * 1000 / (perimeter * sumK * 100)
//
// Full formula per product — see comments inside.

import '../models/material_entry.dart';
import '../models/cost_entry.dart';

enum ProductType {
  zipperBag,
  sliderBag,
  doypakBag,
  csBag,
  quattroBag,
  sideSealBag,
  label,
  sleeve,
  swBags,
  tssBag,
  roll,
}

extension ProductTypeExt on ProductType {
  String get displayName {
    switch (this) {
      case ProductType.zipperBag:
        return 'Zipper Bag';
      case ProductType.sliderBag:
        return 'Slider Bag';
      case ProductType.doypakBag:
        return 'Doypack Bag';
      case ProductType.csBag:
        return 'C.S. Bag';
      case ProductType.quattroBag:
        return 'Quattro bag';
      case ProductType.sideSealBag:
        return 'Side seal Bag';
      case ProductType.label:
        return 'label';
      case ProductType.sleeve:
        return 'Sleeve';
      case ProductType.swBags:
        return 'S.W.bags';
      case ProductType.tssBag:
        return 'T.S.S. Bag';
      case ProductType.roll:
        return 'ROLL';
    }
  }

  bool get hasGusset =>
      this == ProductType.zipperBag ||
      this == ProductType.sliderBag ||
      this == ProductType.doypakBag ||
      this == ProductType.quattroBag ||
      this == ProductType.sideSealBag ||
      this == ProductType.sleeve;

  bool get hasQty => this != ProductType.roll;

  /// Which dimension is used for METERS/QTY (true = W/C, false = L/B)
  bool get metersQtyUsesW {
    switch (this) {
      case ProductType.zipperBag:
      case ProductType.sliderBag:
      case ProductType.doypakBag:
      case ProductType.swBags:
        return true; // C * qty / 100
      case ProductType.csBag:
      case ProductType.quattroBag:
      case ProductType.sideSealBag:
      case ProductType.label:
      case ProductType.sleeve:
      case ProductType.tssBag:
        return false; // B * qty / 100
      default:
        return false;
    }
  }
}

class LayerResult {
  /// Weight of one unit in grams
  final double weightUnitGr;

  /// Total weight for job in kg
  final double weightKg;

  /// Meters/Qty = meters of roll needed for the quantity
  final double metersQty;

  /// Meters/Kg
  final double metersKg;

  /// Cost per kg of material (if available)
  final double? materialCostPerKg;

  /// Layer consumption details (weight per layer in kg)
  final List<double> layerWeightsKg;

  const LayerResult({
    required this.weightUnitGr,
    required this.weightKg,
    required this.metersQty,
    required this.metersKg,
    this.materialCostPerKg,
    required this.layerWeightsKg,
  });
}

class MeteringResult {
  final LayerResult? layer1Result;
  final LayerResult? layer2Result;
  final LayerResult? layer3Result;
  final LayerResult? layer4Result;

  // ROLL-specific
  final double? rollLengthM1;
  final double? rollLengthM2;
  final double? rollLengthM3;
  final double? rollLengthM4;

  const MeteringResult({
    this.layer1Result,
    this.layer2Result,
    this.layer3Result,
    this.layer4Result,
    this.rollLengthM1,
    this.rollLengthM2,
    this.rollLengthM3,
    this.rollLengthM4,
  });
}

class CalculatorEngine {
  final Map<String, double> _materialMap; // name -> weightFactor (col G)
  final Map<String, double> _materialColF; // name -> colF (col F, used for ROLL)
  final Map<String, double> _costMap;

  CalculatorEngine({
    required List<MaterialEntry> materials,
    required List<CostEntry> costs,
  })  : _materialMap = {
          for (final m in materials)
            if (m.weightFactor != null) m.name: m.weightFactor!,
        },
        _materialColF = {
          for (final m in materials)
            if (m.colF != null) m.name: m.colF!,
        },
        _costMap = {
          for (final c in costs) c.name: c.cost,
        };

  double? _wf(String name) => _materialMap[name];
  double? _cf(String name) => _materialColF[name];
  double? _cost(String name) => _costMap[name];

  /// Main calculation entry point.
  ///
  /// [layers] is a list of 1–4 material names (in order).
  /// Pass the number of layers you want results for.
  MeteringResult calculate({
    required ProductType product,
    required double l, // L (cm)
    required double w, // W (cm)
    required double g, // G (cm)
    required double qty, // qty/pcs  (ignored for ROLL)
    required int numLayers, // 1-4
    required List<String> layers, // [l1, l2, l3, l4]
  }) {
    assert(layers.length == 4);

    if (product == ProductType.roll) {
      return _calculateRoll(l: l, w: w, layers: layers, numLayers: numLayers);
    }

    LayerResult? r1, r2, r3, r4;
    if (numLayers >= 1) {
      r1 = _calcStructure(product, l, w, g, qty, [layers[0]]);
    }
    if (numLayers >= 2) {
      r2 = _calcStructure(product, l, w, g, qty, [layers[0], layers[1]]);
    }
    if (numLayers >= 3) {
      r3 = _calcStructure(product, l, w, g, qty, [layers[0], layers[1], layers[2]]);
    }
    if (numLayers >= 4) {
      r4 = _calcStructure(product, l, w, g, qty, layers);
    }

    return MeteringResult(
      layer1Result: r1,
      layer2Result: r2,
      layer3Result: r3,
      layer4Result: r4,
    );
  }

  // ----------------------------------------------------------------
  // Per-product "perimeter" or geometry factor
  // Returns the cm-factor used in weight formula:
  //   weightUnit = factor * sumKn  [+ bonus]
  // ----------------------------------------------------------------

  /// Returns {factor, bonus} for weight/unit calculation.
  /// factor * sumK + bonus = weight in grams per unit
  _FactorBonus _geometry(ProductType p, double l, double w, double g) {
    switch (p) {
      // Zipper Bag: K4 = (((B*2)+G)*W*k) + (0.08*W)
      // factor = (L*2+G)*W,  bonus = 0.08*W
      case ProductType.zipperBag:
      case ProductType.sliderBag:
        return _FactorBonus(factor: (l * 2 + g) * w, bonus: 0.08 * w);

      // Doypack: K6 = ((L*2)+G)*W*k  — no bonus
      case ProductType.doypakBag:
        return _FactorBonus(factor: (l * 2 + g) * w, bonus: 0.0);

      // C.S. Bag: K7 = ((W+G)*2+3)*L*k  — no bonus
      case ProductType.csBag:
        return _FactorBonus(factor: ((w + g) * 2 + 3) * l, bonus: 0.0);

      // Quattro bag: K8 = (W+G)*2*L*k
      case ProductType.quattroBag:
        return _FactorBonus(factor: (w + g) * 2 * l, bonus: 0.0);

      // Side seal: K9 = ((W+G)*2+1.5)*L*k
      case ProductType.sideSealBag:
        return _FactorBonus(factor: ((w + g) * 2 + 1.5) * l, bonus: 0.0);

      // label: K10 = (W*2+1)*L*k
      case ProductType.label:
        return _FactorBonus(factor: (w * 2 + 1) * l, bonus: 0.0);

      // Sleeve: K11 = (W*2+1)*L*k
      case ProductType.sleeve:
        return _FactorBonus(factor: (w * 2 + 1) * l, bonus: 0.0);

      // S.W.bags: K12 = (L*2+G)*W*k  (same as zipper but no bonus)
      case ProductType.swBags:
        return _FactorBonus(factor: (l * 2 + g) * w, bonus: 0.0);

      // T.S.S. Bag: K13 = (L*2+G)*W*k
      case ProductType.tssBag:
        return _FactorBonus(factor: (l * 2 + g) * w, bonus: 0.0);

      case ProductType.roll:
        return _FactorBonus(factor: l * w, bonus: 0.0);
    }
  }

  /// Effective perimeter for METERS/KG denominator (cm-based)
  double _perimForMeters(ProductType p, double l, double w, double g) {
    return _geometry(p, l, w, g).factor;
  }

  LayerResult _calcStructure(
    ProductType product,
    double l,
    double w,
    double g,
    double qty,
    List<String> layerNames,
  ) {
    final fb = _geometry(product, l, w, g);
    final double factor = fb.factor;
    final double bonus = fb.bonus;

    // sum of weight factors
    double sumK = 0.0;
    final List<double> kValues = [];
    for (final name in layerNames) {
      final k = _wf(name) ?? 0.0;
      kValues.add(k);
      sumK += k;
    }

    // weight per unit in grams
    final double weightUnitGr = factor * sumK + bonus;

    // weight in kg for full job — bonus already included in weightUnit
    // F4 = E * (K4 - bonus) / 1000  wait — Excel formula for zipper:
    // F4 = E4*(K4-(0.08*C4))/1000  where K4 already includes the 0.08*C4 bonus
    // So WEIGHT/KG = qty * (weightUnit - bonus) / 1000
    final double weightKg = qty * (weightUnitGr - bonus) / 1000.0;

    // METERS/QTY
    double metersQty;
    switch (product) {
      case ProductType.zipperBag:
      case ProductType.sliderBag:
      case ProductType.doypakBag:
      case ProductType.swBags:
        metersQty = w * qty / 100.0; // C * E / 100
        break;
      case ProductType.csBag:
      case ProductType.quattroBag:
      case ProductType.sideSealBag:
      case ProductType.label:
      case ProductType.sleeve:
      case ProductType.tssBag:
        metersQty = l * qty / 100.0; // B * E / 100
        break;
      default:
        metersQty = w * qty / 100.0;
    }

    // METERS/KG = (weightKg * 1000) / (perimeter * sumK * 100)
    double metersKg = 0.0;
    if (sumK > 0 && factor > 0) {
      metersKg = (weightKg * 1000.0) / (factor * sumK * 100.0);
    }

    // Layer weight breakdown: each layer = qty * factor * kN / 1000
    final layerWeightsKg = kValues.map((k) => qty * factor * k / 1000.0).toList();

    // Cost per kg (based on last layer name for single layer, or combined)
    double? costPerKg;
    if (layerNames.length == 1) {
      costPerKg = _cost(layerNames[0]);
    }

    return LayerResult(
      weightUnitGr: weightUnitGr,
      weightKg: weightKg,
      metersQty: metersQty,
      metersKg: metersKg,
      materialCostPerKg: costPerKg,
      layerWeightsKg: layerWeightsKg,
    );
  }

  // ----------------------------------------------------------------
  // ROLL — special formulas
  // ----------------------------------------------------------------
  // From Excel row 14:
  //   B14=1 (lines), C14=35 (width cm), F14=350 (weight kg fixed input)
  //   K14 = C*B*k1                         (weight/unit per meter)
  //   L14 (METERS/QTY) = (F14/(K21*C14)*1000)/B19   — K21 = weight/layer row
  //   For simplified: METERS/QTY = F14 / (K14) * 1000   (length from weight)
  //   WEIGHT/KG displayed = F14 directly (user input weight)
  //
  // Here L=lines (default 1), W=width (cm), and we treat F=weightKg as input
  // The "qty" field for ROLL is treated as weight in KG.

  MeteringResult _calculateRoll({
    required double l,   // lines (default 1)
    required double w,   // width in cm
    required List<String> layers,
    required int numLayers,
  }) {
    // For ROLL the "L" input is treated as weight in KG (same as Excel F14=350)
    // and "W" is the roll width in cm. "lines" = 1 by default.
    // We repurpose: l = weightKg input, w = roll width cm

    double? rollLen1, rollLen2, rollLen3, rollLen4;
    LayerResult? r1, r2, r3, r4;

    final double weightKg = l; // user enters weight in KG for ROLL

    if (numLayers >= 1) {
      final k1 = _wf(layers[0]) ?? 0.0;
      final f1 = _cf(layers[0]) ?? 0.0;
      // K14 = w * 1 * k1
      final k14 = w * k1;
      // METERS/QTY = (weightKg / (K21*w) * 1000) / lines
      // K21 = layer weight/meter = w * k1 (same as K14 for 1 layer)
      final len = k14 > 0 ? (weightKg * 1000.0) / (k14 * 100.0) : 0.0;
      rollLen1 = len;
      r1 = LayerResult(
        weightUnitGr: k14,
        weightKg: weightKg,
        metersQty: len,
        metersKg: k1 > 0 ? 1000.0 / (k1 * w * 100.0) : 0.0,
        layerWeightsKg: [weightKg],
      );
    }

    if (numLayers >= 2) {
      final k1 = _wf(layers[0]) ?? 0.0;
      final k2 = _wf(layers[1]) ?? 0.0;
      final sumK = k1 + k2;
      final len = sumK > 0 ? (weightKg * 1000.0) / (sumK * w * 100.0) : 0.0;
      rollLen2 = len;
      r2 = LayerResult(
        weightUnitGr: sumK * w,
        weightKg: weightKg,
        metersQty: len,
        metersKg: sumK > 0 ? 1000.0 / (sumK * w * 100.0) : 0.0,
        layerWeightsKg: [
          len * w * k1 / 1000.0,
          len * w * k2 / 1000.0,
        ],
      );
    }

    if (numLayers >= 3) {
      final k1 = _wf(layers[0]) ?? 0.0;
      final k2 = _wf(layers[1]) ?? 0.0;
      final k3 = _wf(layers[2]) ?? 0.0;
      final sumK = k1 + k2 + k3;
      final len = sumK > 0 ? (weightKg * 1000.0) / (sumK * w * 100.0) : 0.0;
      rollLen3 = len;
      r3 = LayerResult(
        weightUnitGr: sumK * w,
        weightKg: weightKg,
        metersQty: len,
        metersKg: sumK > 0 ? 1000.0 / (sumK * w * 100.0) : 0.0,
        layerWeightsKg: [
          len * w * k1 / 1000.0,
          len * w * k2 / 1000.0,
          len * w * k3 / 1000.0,
        ],
      );
    }

    if (numLayers >= 4) {
      final sumK = (layers.map((n) => _wf(n) ?? 0.0)).reduce((a, b) => a + b);
      final len = sumK > 0 ? (weightKg * 1000.0) / (sumK * w * 100.0) : 0.0;
      rollLen4 = len;
      r4 = LayerResult(
        weightUnitGr: sumK * w,
        weightKg: weightKg,
        metersQty: len,
        metersKg: sumK > 0 ? 1000.0 / (sumK * w * 100.0) : 0.0,
        layerWeightsKg: layers.map((n) => len * w * (_wf(n) ?? 0.0) / 1000.0).toList(),
      );
    }

    return MeteringResult(
      layer1Result: r1,
      layer2Result: r2,
      layer3Result: r3,
      layer4Result: r4,
      rollLengthM1: rollLen1,
      rollLengthM2: rollLen2,
      rollLengthM3: rollLen3,
      rollLengthM4: rollLen4,
    );
  }

  /// Cost lookup by material name (VLOOKUP equivalent)
  double? lookupCost(String materialName) => _cost(materialName);

  List<String> get materialNames => List.unmodifiable(_materialMap.keys);
  List<String> get costNames => List.unmodifiable(_costMap.keys);
}

class _FactorBonus {
  final double factor;
  final double bonus;
  const _FactorBonus({required this.factor, required this.bonus});
}
