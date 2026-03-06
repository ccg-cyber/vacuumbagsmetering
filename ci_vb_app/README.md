# Ci™ Metering Support — Vacuum Bags SARL v2.1

[![Build Android APK](../../actions/workflows/build-apk.yml/badge.svg)](../../actions/workflows/build-apk.yml)

**Premium factory-side packaging calculator for [Vacuum Bags SARL](https://vacuumbags.com.lb)**

> Developed and powered by [CCG — Cyber Consulting Group](https://ccg.support)

A Flutter app that faithfully reproduces the logic of `Metering_support_2_1.xlsx`, running fully offline on Windows desktop and Android mobile.

---

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.0.0 (https://docs.flutter.dev/get-started/install)
- For Android: Android Studio / NDK
- For Windows: Visual Studio 2022 with C++ workload

### Build & Run

```bash
# Clone / unzip the project
cd vacuum_bags_sarl

# Install dependencies
flutter pub get

# Run on connected Android device
flutter run

# Build Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Enable Windows desktop
flutter config --enable-windows-desktop
flutter create --platforms windows .

# Build Windows EXE
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### Run Tests
```bash
flutter test test/calculator_engine_test.dart
```

### CI/CD (GitHub Actions)

The repository includes a GitHub Actions workflow that automatically:
1. Runs the formula verification tests
2. Builds the release APK
3. Uploads the APK as a downloadable artifact

Navigate to **Actions → Build Android APK** in the GitHub repository to download the latest APK.

---

## App Structure

```
lib/
├── main.dart                    # Entry point, MaterialApp, BottomNav
├── theme.dart                   # Light / Dark themes
├── models/
│   ├── material_entry.dart      # Material (Sheet2 row)
│   ├── cost_entry.dart          # Cost (Sheet4 row)
│   └── saved_job.dart           # Saved calculation job
├── services/
│   ├── calculator_engine.dart   # ★ Core formula engine
│   ├── data_repository.dart     # Hive persistence + seed
│   └── export_service.dart      # PDF + CSV export
├── providers/
│   └── app_providers.dart       # Riverpod state management
├── screens/
│   ├── calculator_screen.dart   # Tab 1: Main calculator
│   ├── materials_screen.dart    # Tab 2: Materials master
│   ├── costs_screen.dart        # Tab 3: Cost master
│   ├── jobs_screen.dart         # Tab 4: Saved jobs
│   └── settings_screen.dart     # Tab 5: Settings / export
└── widgets/
    ├── result_card.dart          # Output card widget
    ├── dim_field.dart            # Numeric input field
    └── layer_selector.dart       # Material dropdown per layer

assets/
├── materials.json               # Seeded from Sheet2 (74 materials)
└── costs.json                   # Seeded from Sheet4 (251 entries)

test/
└── calculator_engine_test.dart  # Formula verification vs Excel
```

---

## Formula Mapping (Excel → Dart)

This section documents how each Excel Sheet1 formula maps to `calculator_engine.dart`.

### Key variable mapping

| Excel cell | Excel meaning | Dart variable |
|---|---|---|
| B | L (cm) | `l` |
| C | W (cm) | `w` |
| D | G (cm, gusset) | `g` |
| E | qty/pcs | `qty` |
| K3/N3/etc | VLOOKUP → Sheet2 col G | `_wf(materialName)` |

### Sheet2 Column G (the weight factor)

The VLOOKUP in Sheet1 row 3 is:
```excel
=VLOOKUP(K2, Sheet2!A3:G504, 7, FALSE)
```
Column G in Sheet2 is:
```
= thickness_um * density / 1_000_000  [g per cm² per cm length]
```
This is stored as `weightFactor` in `MaterialEntry`.

### Product geometry formulas

Each product type maps to a Dart `_geometry()` case:

#### Zipper Bag / Slider Bag
```excel
K4 = (((B4*2)+D4)*C4*K3)+(0.08*C4)
F4 = E4*(K4-(0.08*C4))/1000
```
```dart
factor = (l*2 + g) * w
bonus  = 0.08 * w
weightUnit = factor * sumK + bonus
weightKg   = qty * (weightUnit - bonus) / 1000
```

#### Doypack Bag (no bonus)
```excel
K6 = ((B6*2)+D6)*C6*K3
F6 = E6*K6/1000
```
```dart
factor = (l*2 + g) * w,  bonus = 0.0
```

#### C.S. Bag
```excel
K7 = (((C7+D7)*2)+3)*B7*K3
```
```dart
factor = ((w + g)*2 + 3) * l
```

#### Quattro Bag
```excel
K8 = (C8+D8)*2*B8*K3
```
```dart
factor = (w + g) * 2 * l
```

#### Side Seal Bag
```excel
K9 = (((C9+D9)*2)+1.5)*B9*K3
```
```dart
factor = ((w + g)*2 + 1.5) * l
```

#### Label / Sleeve
```excel
K10 = ((C10*2)+1)*B10*K3
```
```dart
factor = (w*2 + 1) * l
```

#### S.W.bags / T.S.S. Bag
```excel
K12 = ((B12*2)+D12)*C12*K3   (no bonus)
```
```dart
factor = (l*2 + g) * w,  bonus = 0.0
```

#### ROLL
```excel
K14 = C14*B14*k     (weight per cm of roll width per meter length)
L14 = (F14/(K21*C14)*1000)/B19
```
The user enters weight in KG in the "L" field. Width goes in "W". METERS/QTY is the roll length:
```dart
len = (weightKg * 1000) / (k1 * width * 100)
```

### METERS/QTY formula

- Zipper, Slider, Doypack, S.W.bags: `W * qty / 100` (width-based)
- All others: `L * qty / 100` (length-based)

### METERS/KG formula
```excel
M4 = F4 / (((B4*2)+D4)*K3*100) * 1000
```
```dart
metersKg = (weightKg * 1000) / (factor * sumK * 100)
```

### Multi-layer: 2, 3, 4 layers

Each structure's `sumK = k1 + k2 + ... + kN`. The same geometry `factor` applies. For Zipper/Slider bags, the bonus only applies to the last layer (innermost PE):
```excel
N4 = (((B4*2)+D4)*C4*N3) + ((((B4*2)+D4)*C4*O3)+(0.08*C4))
```
The `+0.08*C4` bonus is included in the last-layer term, so:
```dart
weightUnit = factor * sumK + bonus   // bonus always 0.08*w for zipper/slider
weightKg   = qty * (weightUnit - bonus) / 1000
```

---

## Data Seed Files

Generated automatically from `Metering_support_2_1.xlsx` by `scripts/extract_seed.py`.

### materials.json (74 entries)
Each entry:
```json
{
  "name": "PE 70",
  "col_b": 644.0,
  "g_m2": 0.644,
  "thickness_um": 70,
  "col_e": 92000.0,
  "col_f": 0.00644,
  "weight_factor": 0.00644
}
```

### costs.json (251 entries)
Each entry:
```json
{ "name": "PE 70", "cost": 1.65 }
```

---

## Features

| Feature | Status |
|---|---|
| All 11 product types | ✅ |
| 1–4 layer structures | ✅ |
| Live recalculation | ✅ |
| 74 materials from Sheet2 | ✅ |
| 251 costs from Sheet4 | ✅ |
| Save / load jobs | ✅ |
| Duplicate jobs | ✅ |
| Export PDF | ✅ |
| Export CSV | ✅ |
| Customer / item code / note | ✅ |
| Dark mode | ✅ |
| Offline-first | ✅ |
| Windows desktop | ✅ (needs `flutter create --platforms windows .`) |
| Android APK | ✅ |
| Formula verification tests | ✅ |

---

## Architecture

- **State management**: Riverpod (StateNotifier + Provider)
- **Local storage**: Hive (NoSQL, offline, fast)
- **Export**: `pdf` + `printing` packages, `share_plus`
- **No internet required** — all data seeded from assets on first run

---

## Factory Usage Tips

1. Select product type → dimensions auto-populate with defaults
2. Enter L, W, G, qty (all in cm / pieces)
3. Select how many layers
4. Pick material for each layer from the dropdown
5. Results update instantly — no submit button needed
6. Tap **Save** icon to name and store the job
7. Open **Jobs** tab to export PDF/CSV or reload into calculator

---

## Credits & Trademark

- **Ci™** is a registered trademark of **Vacuum Bags SARL**
- **Website**: [vacuumbags.com.lb](https://vacuumbags.com.lb)
- **Developed & Powered by**: [CCG — Cyber Consulting Group](https://ccg.support)
- All rights reserved © 2024–2026 Vacuum Bags SARL
