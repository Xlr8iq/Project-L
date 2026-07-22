# 🦷 Lumina (لومينا) — Clinical Dental Management System

**Lumina** is a modern, high-performance, professional dental clinic management application built with Flutter. Designed to emulate top-tier commercial dental software (Dentrix, OpenDental, Carestream), Lumina features an authentic **Palmer Notation Odontogram**, comprehensive clinical treatment workflows, bilingual support (English/Arabic), patient management, and custom PDF prescription printing.

---

## 🌟 Key Features

### 1. 📋 Palmer Notation Clinical Odontogram
- **Authentic 4-Quadrant Palmer Chart**: Built according to clinical dentist orientation:
  ```
  Upper Right | Upper Left
  ------------+------------
  Lower Right | Lower Left
  ```
- **Authentic Palmer Brackets**: Precision rendering of Palmer bracket symbols (`┘8`..`┘1`, `└1`..`└8`, `┐8`..`┐1`, `┌1`..`┌8`).
- **3dp Clinical Blue Cross Divider (`#1565C0`)**: Continuous intersecting cross divider.
- **Anatomical Monochrome Tooth Vectors**: Realistic root bifurcations, CEJ boundary curves, and occlusal cusp lines for all 8 tooth shapes (Incisors, Canines, Premolars, Molars).
- **Interactive 5-Surface Diagram**: Dynamic surface selector for Mesial, Distal, Buccal/Labial, Lingual/Palatal, and Occlusal/Incisal surfaces.

### 2. ⚡ Clinical Treatment Workflow
- **Instant Procedure Selection**: Select any tooth to immediately access 1-tap treatment actions:
  - **Composite (Restoration)** — Blue indicator
  - **Root Canal (Endodontic)** — Orange indicator
  - **Crown** — Amber/Gold indicator
  - **Extraction** — Red indicator
  - **Implant** — Grey indicator
  - **Veneer** — Purple indicator
  - **Sealant** — Teal indicator
- **Procedure Color Overlays**: Visually highlights treated tooth crowns and roots directly on the chart.

### 3. 🌐 Bilingual & Localization (English & Arabic)
- **Full RTL Support**: Seamless right-to-left layout adaptation when switched to Arabic.
- **Dynamic Translation Engine**: On-the-fly language toggling across all screens and printed reports.

### 4. 🖨️ Prescription Management & PDF Generator
- **Branded Prescription Header**: Custom clinic logo upload, clinic name, address, and doctor license information.
- **Embedded Amiri Fonts**: Crisp Arabic typography rendering on exported PDF prescriptions.

### 5. 👥 Patient Database & Calendar
- **Patient Profiles**: Comprehensive demographic tracking, registration timestamps, and full historical appointment logs.
- **Calendar & Appointment Scheduler**: Day-by-day filter ribbon, checkup booking, and status updates (Scheduled/Completed).

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Desktop Windows, Linux, macOS & Web ready)
- **Language**: Dart
- **State Management**: Provider (`ChangeNotifierProvider`, `MultiProvider`)
- **Database**: SQLite (`sqflite_common_ffi` for desktop persistence)
- **PDF & Printing**: `pdf` & `printing` packages with bundled `Amiri` TrueType fonts
- **Typography**: Google Fonts (Inter & Outfit)

---

## 🚀 Getting Started

### Prerequisites

Ensure you have Flutter SDK installed (3.x or newer):
```bash
flutter --version
```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Xlr8iq/Project-L.git
   cd Project-L
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application on Windows Desktop:
   ```bash
   flutter run -d windows
   ```

---

## 📂 Project Architecture

```
lib/
├── core/
│   ├── database/          # SQLite DatabaseHelper & persistence
│   ├── localization/      # Translations dictionary (AR/EN)
│   ├── models/            # Tooth, Patient, Appointment models
│   ├── services/          # Settings storage & prefs
│   ├── utils/             # PDF prescription generator
│   └── theme.dart         # Clinical light theme design system (#1565C0)
├── features/
│   ├── appointments/      # Calendar view, add appointment screen
│   ├── dashboard/         # Overview stats, clinic & settings providers
│   ├── odontogram/        # PalmerChart, ToothPainter, ToothDetailPanel
│   ├── patients/          # Patient database tab, patient profile screen
│   └── settings/          # Prescription template editor
└── main.dart              # Application entrypoint & MultiProvider setup
```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
