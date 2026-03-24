 **Clean Architecture สำหรับ Flutter + Provider + SQLite**
---

# 📂 โครงสร้างหลัก (Clean Architecture)

```
lib/
│
├── core/
│   ├── constants/
│   ├── error/
│   ├── utils/
│   ├── theme/
│   └── widgets/        # shared widgets (button, card, etc.)
│
├── features/
│   ├── timer/
│   ├── category/
│   ├── stats/
│   ├── gacha/
│   └── animals/
│
├── injection_container.dart
└── main.dart
```

👉 แนวคิด:

* แยกตาม **feature** (สำคัญมาก)
* แต่ละ feature แบ่งเป็น 3 layer:

  * data
  * domain
  * presentation

---

# 🧩 โครงสร้างในแต่ละ Feature

## 📌 ตัวอย่าง: `timer/`

```
features/timer/
│
├── data/
│   ├── datasources/
│   │   └── timer_local_datasource.dart
│   │
│   ├── models/
│   │   └── timer_model.dart
│   │
│   └── repositories/
│       └── timer_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── timer.dart
│   │
│   ├── repositories/
│   │   └── timer_repository.dart
│   │
│   └── usecases/
│       ├── start_timer.dart
│       ├── pause_timer.dart
│       └── reset_timer.dart
│
└── presentation/
    ├── providers/
    │   └── timer_provider.dart
    │
    ├── pages/
    │   └── timer_page.dart
    │
    └── widgets/
        ├── timer_circle.dart
        └── timer_controls.dart
```

---

# 🧠 อธิบายแต่ละ Layer (เข้าใจให้ตรง = โค้ดไม่เละ)

## 1. 🟡 Domain (แกนของระบบ)

> “ห้ามรู้เรื่อง Flutter / SQLite”

* `entities/` → object หลัก (Timer, Category)
* `repositories/` → abstract class
* `usecases/` → business logic

👉 เช่น:

* StartTimer
* CalculateCoins

---

## 2. 🔵 Data Layer

> “ทำงานกับ SQLite / API”

* `models/` → map JSON / DB
* `datasources/` → SQLite query
* `repositories_impl/` → implement domain repo

---

## 3. 🟢 Presentation Layer

> “UI + State”

* `pages/` → screen
* `widgets/` → UI ย่อย
* `providers/` → ChangeNotifier

---

# 📦 Feature อื่น ๆ (โครงเหมือนกันหมด)

---

## 🗂️ category/

```
category/
├── data/
│   ├── datasources/category_local_datasource.dart
│   ├── models/category_model.dart
│   └── repositories/category_repository_impl.dart
│
├── domain/
│   ├── entities/category.dart
│   ├── repositories/category_repository.dart
│   └── usecases/
│       ├── get_categories.dart
│       ├── add_category.dart
│       └── delete_category.dart
│
└── presentation/
    ├── providers/category_provider.dart
    ├── pages/category_page.dart
    └── widgets/
```

---

## 📊 stats/

```
stats/
├── data/
│   ├── datasources/stats_local_datasource.dart
│   └── repositories/stats_repository_impl.dart
│
├── domain/
│   ├── entities/stats.dart
│   ├── repositories/stats_repository.dart
│   └── usecases/
│       ├── get_stats.dart
│       └── get_summary.dart
│
└── presentation/
    ├── providers/stats_provider.dart
    ├── pages/stats_page.dart
    └── widgets/
```

---

## 🎲 gacha/

```
gacha/
├── data/
│   ├── datasources/gacha_local_datasource.dart
│   └── repositories/gacha_repository_impl.dart
│
├── domain/
│   ├── entities/gacha_result.dart
│   ├── repositories/gacha_repository.dart
│   └── usecases/
│       └── draw_gacha.dart
│
└── presentation/
    ├── providers/gacha_provider.dart
    ├── pages/gacha_page.dart
    └── widgets/
```

---

## 🐾 animals/

```
animals/
├── data/
│   ├── datasources/animal_local_datasource.dart
│   ├── models/animal_model.dart
│   └── repositories/animal_repository_impl.dart
│
├── domain/
│   ├── entities/animal.dart
│   ├── repositories/animal_repository.dart
│   └── usecases/
│       ├── get_animals.dart
│       └── get_unlocked_animals.dart
│
└── presentation/
    ├── providers/animal_provider.dart
    ├── pages/animal_page.dart
    ├── pages/animal_detail_page.dart
    └── widgets/
```

---

# 🧱 Core (Shared)

```
core/
├── constants/
│   ├── colors.dart
│   └── app_constants.dart
│
├── theme/
│   └── app_theme.dart
│
├── error/
│   └── exceptions.dart
│
├── utils/
│   └── helpers.dart
│
└── widgets/
    ├── app_button.dart
    └── app_card.dart
```

---

# 🔌 Dependency Injection

```
injection_container.dart
```

👉 ใช้ register:

* repositories
* datasources
* providers

(ใช้ get_it หรือ manual ก็ได้)

---

# 🚀 main.dart (MultiProvider)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TimerProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => StatsProvider()),
    ChangeNotifierProvider(create: (_) => GachaProvider()),
    ChangeNotifierProvider(create: (_) => AnimalProvider()),
  ],
  child: MyApp(),
);
```

---

# 🎯 Key Rules (สำคัญมาก)

❗ Domain ห้าม import:

* Flutter
* sqflite

❗ Data ห้ามยุ่ง UI

❗ Provider ห้ามเขียน logic หนัก
→ ไปอยู่ UseCase

---

# 💡 Pro Tips (จากของจริง)

* เริ่มจาก **Timer feature ก่อน**
* ใช้ `barrel file` (export) ลด import ยาว
* ตั้งชื่อให้ consistent:

  * `*_repository.dart`
  * `*_repository_impl.dart`

---

* แยก **feature-first**
* แต่ละ feature มี:

  * data / domain / presentation
* scale ได้
* refactor ง่าย