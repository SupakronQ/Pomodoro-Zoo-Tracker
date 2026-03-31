# 📦 DatabaseHelper - เอกสารอธิบาย

## มันคืออะไร?

`DatabaseHelper` คือ **ตัวจัดการฐานข้อมูล SQLite** ของแอป Pomodoro Zoo Tracker
ทำหน้าที่เป็น **จุดเดียว** ที่ทุกส่วนของแอปจะเข้าถึง Database ผ่านตรงนี้

---

## 🧠 Singleton Pattern

```dart
static final DatabaseHelper _instance = DatabaseHelper._internal();
factory DatabaseHelper() => _instance;
```

ไม่ว่า `DatabaseHelper()` กี่ครั้ง ก็ได้ตัวเดิมเสมอ → ป้องกัน connection ซ้ำซ้อน

---

## 📂 การเปิด Database

- ถ้า DB ยังไม่เคยเปิด → สร้างไฟล์ `pomodoro_zoo.db`
- ถ้าเปิดแล้ว → ส่งตัวเดิมกลับเลย
- **เปิด foreign keys** ผ่าน `PRAGMA foreign_keys = ON`

---

## 🏗️ ตารางทั้งหมด (12 ตาราง)

### 🧑 Core Tables

| ตาราง | คำอธิบาย |
|-------|----------|
| `users` | ข้อมูลผู้ใช้ (username, coin_balance, streak) |
| `categories` | หมวดหมู่โฟกัส เช่น Work, Study (มี color_hex) |
| `goals` | เป้าหมาย (title, target_intervals, deadline, status) |
| `pomodoro_sessions` | บันทึก session จับเวลา (duration, coins_earned, status) |

### 💰 Coin System

| ตาราง | คำอธิบาย |
|-------|----------|
| `transaction_types` | ประเภท transaction เช่น "pomodoro_reward", "gacha_pull" |
| `coin_transactions` | ประวัติธุรกรรมเหรียญ (amount, reference_id) |

### 🎲 Gacha System

| ตาราง | คำอธิบาย |
|-------|----------|
| `rarities` | ระดับความหายาก (Common 70%, Rare 25%, Epic 5%) |
| `item_types` | ประเภทไอเทม เช่น "animal", "decoration", "background" |
| `gacha_items` | ไอเทมที่สุ่มได้ (name, description, sprite_url) |
| `user_inventory` | ของที่ user สุ่มได้แล้ว (level, exp, status) |

### 🍖 Food System

| ตาราง | คำอธิบาย |
|-------|----------|
| `food_store` | ร้านค้าอาหาร (name, price, benefit_value) |
| `user_foods` | อาหารที่ user ซื้อแล้ว (quantity) |

---

## 🔗 Relationships (FK)

```
users ← coin_transactions, goals, categories, pomodoro_sessions, user_foods, user_inventory
categories ← pomodoro_sessions
goals ← pomodoro_sessions
transaction_types ← coin_transactions
rarities ← gacha_items
item_types ← gacha_items
gacha_items ← user_inventory
food_store ← user_foods
user_inventory - users.showcased_animal_id
```

---

## 🔑 Primary Key = UUID

ทุกตารางใช้ **UUID v4** เป็น primary key (เก็บเป็น `TEXT`)
→ generate ด้วย `Uuid().v4()` จาก package `uuid`

---

## 🌱 ข้อมูลเริ่มต้น (Seed Data)

| ตาราง | ข้อมูล |
|-------|--------|
| `transaction_types` | pomodoro_reward, gacha_pull, food_purchase |
| `rarities` | Common (70), Rare (25), Epic (5) |
| `item_types` | animal, decoration, background |
| `categories` | Work (#4CAF50), Study (#2196F3) |

---

## 🔄 Migration System

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // if (oldVersion < 2) { ... }
}
```

เวลาอัป version → เขียน migration step-by-step → ผู้ใช้ไม่สูญเสียข้อมูลเดิม

---

## 💡 สรุปฟังก์ชัน

| ฟังก์ชัน | ทำอะไร |
|----------|--------|
| `database` (getter) | เปิด/คืน Database instance |
| `_initDatabase()` | สร้างไฟล์ DB + เปิด connection |
| `_onConfigure()` | เปิด foreign keys |
| `_onCreate()` | สร้าง 12 ตาราง + seed lookup data |
| `_seedLookupTables()` | ใส่ข้อมูลเริ่มต้นให้ lookup tables |
| `_onUpgrade()` | จัดการ migration |
| `close()` | ปิด connection |
