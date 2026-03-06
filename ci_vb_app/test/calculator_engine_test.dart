// test/calculator_engine_test.dart
//
// Formula verification suite — compares app output against known Excel
// sample values from Metering_support_2_1.xlsx Sheet1.
//
// Reference data taken from rows 4-14 of Sheet1 with:
//   1-layer  = PE 70      (weightFactor = 0.00644)
//   2-layers = PET12/PE90 (0.00168 + 0.00828)
//   3-layers = PET12/CPA20/PE70 (0.00168 + 0.0026 + 0.00644)
//   4-layers = CPP30/MET18/ALU9/PE60 (0.00273 + 0.001638 + 0.002160 + 0.00552)

import 'package:test/test.dart';
import 'package:ci_vb_metering/services/calculator_engine.dart';
import 'package:ci_vb_metering/models/material_entry.dart';
import 'package:ci_vb_metering/models/cost_entry.dart';

// ---- Seed data matching Sheet2 exactly ----
final _seedMaterials = [
  MaterialEntry(name: 'PE 70',  weightFactor: 0.00644),
  MaterialEntry(name: 'PE 90',  weightFactor: 0.00828),
  MaterialEntry(name: 'PE 60',  weightFactor: 0.00552),
  MaterialEntry(name: 'PET 12', weightFactor: 0.001680),
  MaterialEntry(name: 'CPA 20', weightFactor: 0.0026),
  MaterialEntry(name: 'CPP 30', weightFactor: 0.00273),
  MaterialEntry(name: 'MET 18', weightFactor: 0.001638),
  MaterialEntry(name: 'ALU 9',  weightFactor: 0.002160),
];

final _seedCosts = <CostEntry>[];

CalculatorEngine _engine() =>
    CalculatorEngine(materials: _seedMaterials, costs: _seedCosts);

const _eps = 0.01; // tolerance

void main() {
  group('Zipper Bag (L=30, W=25, G=8, qty=41100)', () {
    final engine = _engine();

    // Expected from Sheet1 row 4
    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.zipperBag,
        l: 30, w: 25, g: 8, qty: 41100, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      expect(r.layer1Result!.weightKg, closeTo(449.96, _eps));
    });

    test('2-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.zipperBag,
        l: 30, w: 25, g: 8, qty: 41100, numLayers: 2,
        layers: ['PET 12', 'PE 90', 'CPA 20', 'PE 60'],
      );
      expect(r.layer2Result!.weightKg, closeTo(695.91, _eps));
    });

    test('METERS/QTY', () {
      final r = engine.calculate(
        product: ProductType.zipperBag,
        l: 30, w: 25, g: 8, qty: 41100, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // METERS/QTY = W * qty / 100 = 25 * 41100 / 100 = 10275
      expect(r.layer1Result!.metersQty, closeTo(10275.0, _eps));
    });
  });

  group('Slider Bag (L=15, W=20, G=5, qty=20000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.sliderBag,
        l: 15, w: 20, g: 5, qty: 20000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      expect(r.layer1Result!.weightKg, closeTo(90.16, _eps));
    });

    test('METERS/QTY', () {
      final r = engine.calculate(
        product: ProductType.sliderBag,
        l: 15, w: 20, g: 5, qty: 20000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // W * qty / 100 = 20 * 20000 / 100 = 4000
      expect(r.layer1Result!.metersQty, closeTo(4000.0, _eps));
    });
  });

  group('Doypack Bag (L=30, W=17, G=8, qty=20000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG (no bonus)', () {
      final r = engine.calculate(
        product: ProductType.doypakBag,
        l: 30, w: 17, g: 8, qty: 20000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (30*2+8)*17 = 68*17 = 1156  weightUnit = 1156 * 0.00644 = 7.44464
      // weightKg = 20000 * 7.44464 / 1000 = 148.89
      expect(r.layer1Result!.weightKg, closeTo(148.89, _eps));
    });
  });

  group('C.S. Bag (L=22.5, W=15, G=0, qty=56100)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.csBag,
        l: 22.5, w: 15, g: 0, qty: 56100, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = ((15+0)*2+3)*22.5 = 33*22.5 = 742.5
      // weightUnit = 742.5 * 0.00644 = 4.7817
      // weightKg = 56100 * 4.7817 / 1000 = 268.25
      expect(r.layer1Result!.weightKg, closeTo(268.25, _eps));
    });

    test('METERS/QTY uses L (B)', () {
      final r = engine.calculate(
        product: ProductType.csBag,
        l: 22.5, w: 15, g: 0, qty: 56100, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // L * qty / 100 = 22.5 * 56100 / 100 = 12622.5
      expect(r.layer1Result!.metersQty, closeTo(12622.5, _eps));
    });
  });

  group('Quattro Bag (L=10, W=25, G=2, qty=50000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.quattroBag,
        l: 10, w: 25, g: 2, qty: 50000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (25+2)*2*10 = 540  weightUnit = 540 * 0.00644 = 3.4776
      // weightKg = 50000 * 3.4776 / 1000 = 173.88
      expect(r.layer1Result!.weightKg, closeTo(173.88, _eps));
    });
  });

  group('Side seal Bag (L=10, W=25, G=2, qty=50000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.sideSealBag,
        l: 10, w: 25, g: 2, qty: 50000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = ((25+2)*2+1.5)*10 = 55.5*10 = 555  weightUnit = 555 * 0.00644 = 3.5742
      // weightKg = 50000 * 3.5742 / 1000 = 178.71
      expect(r.layer1Result!.weightKg, closeTo(178.71, _eps));
    });
  });

  group('Label (L=16.25, W=11.8, G=0, qty=6000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.label,
        l: 16.25, w: 11.8, g: 0, qty: 6000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (11.8*2+1)*16.25 = 24.6*16.25 = 399.75
      // weightUnit = 399.75 * 0.00644 = 2.57439
      // weightKg = 6000 * 2.57439 / 1000 = 15.4463
      expect(r.layer1Result!.weightKg, closeTo(15.45, _eps));
    });
  });

  group('Sleeve (L=10, W=25, G=2, qty=73000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.sleeve,
        l: 10, w: 25, g: 2, qty: 73000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (25*2+1)*10 = 510  weightUnit = 510 * 0.00644 = 3.2844
      // weightKg = 73000 * 3.2844 / 1000 = 239.76
      expect(r.layer1Result!.weightKg, closeTo(239.76, _eps));
    });
  });

  group('S.W.bags (L=35, W=65.5, G=0, qty=120000)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.swBags,
        l: 35, w: 65.5, g: 0, qty: 120000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (35*2+0)*65.5 = 70*65.5 = 4585
      // weightUnit = 4585 * 0.00644 = 29.5274
      // weightKg = 120000 * 29.5274 / 1000 = 3543.29
      expect(r.layer1Result!.weightKg, closeTo(3543.29, _eps));
    });
  });

  group('T.S.S. Bag (L=40, W=45, G=0, qty=25)', () {
    final engine = _engine();

    test('1-layer WEIGHT/KG', () {
      final r = engine.calculate(
        product: ProductType.tssBag,
        l: 40, w: 45, g: 0, qty: 25, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (40*2+0)*45 = 3600  weightUnit = 3600 * 0.00644 = 23.184
      // weightKg = 25 * 23.184 / 1000 = 0.5796
      expect(r.layer1Result!.weightKg, closeTo(0.5796, _eps));
    });
  });

  group('ROLL (width=35cm, weightKg=350)', () {
    final engine = _engine();

    test('1-layer METERS/QTY (roll length)', () {
      final r = engine.calculate(
        product: ProductType.roll,
        l: 350, // weight in kg
        w: 35,  // width cm
        g: 0, qty: 0, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // K14 = 35 * 0.00644 = 0.2254
      // len = 350 * 1000 / (0.2254 * 100) = 350000 / 22.54 ≈ 15527.95
      expect(r.layer1Result!.metersQty, closeTo(15527.95, 1.0));
    });
  });

  group('Geometry formula validation', () {
    final engine = _engine();

    test('Zipper bonus = 0.08 * W applied correctly', () {
      final r = engine.calculate(
        product: ProductType.zipperBag,
        l: 10, w: 10, g: 0, qty: 1000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = (10*2+0)*10 = 200,  bonus = 0.08*10 = 0.8
      // weightUnit = 200*0.00644 + 0.8 = 1.288 + 0.8 = 2.088
      // weightKg = 1000 * (2.088 - 0.8) / 1000 = 1.288
      expect(r.layer1Result!.weightKg, closeTo(1.288, 0.001));
    });

    test('Doypack no bonus', () {
      final r = engine.calculate(
        product: ProductType.doypakBag,
        l: 10, w: 10, g: 0, qty: 1000, numLayers: 1,
        layers: ['PE 70', 'PE 90', 'CPA 20', 'PE 60'],
      );
      // factor = 20*10 = 200,  no bonus
      // weightUnit = 200 * 0.00644 = 1.288
      // weightKg = 1000 * 1.288 / 1000 = 1.288
      expect(r.layer1Result!.weightKg, closeTo(1.288, 0.001));
    });
  });
}
