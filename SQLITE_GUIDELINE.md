# แนวทางการเชื่อมต่อ SQLite และการสร้าง ฟังก์ชันใหม่ (Clean Architecture)

โปรเจกต์นี้ใช้โครงสร้างแบบ **Clean Architecture** ร่วมกับ **Provider** ในการจัดการ State ดังนั้นเพื่อความเป็นระเบียบและให้ Developer ทุกคนทำงานในมาตรฐานเดียวกัน เมื่อต้องการสร้างฟังก์ชันใหม่เพื่อเข้าถึงฐานข้อมูล (SQLite) ให้ปฏิบัติตาม Layer และ Folder ดังนี้:

---

## 🏗 ภาพรวมของ Data Flow
เมื่อเชื่อมต่อฐานข้อมูล ฟังก์ชันจะถูกเรียกใช้งานผ่าน Layer ต่างๆ จากล่างขึ้นบน ดังนี้:
1. **Local DataSource** (`data/datasources`) -> เขียนคำสั่ง SQL (`db.insert`, `db.query`)
2. **Repository** (`domain/repositories` & `data/repositories`) -> เป็นตัวกลางประสานงาน
3. **Use Case** (`domain/usecases`) -> แยก Business Logic ออกมาฟังก์ชันละคล่าวๆ
4. **Provider** (`presentation/providers`) -> นำ Use Case ไปใช้งานร่วมกับ UI
5. **Dependency Injection** (`main.dart` หรือ `injection_container.dart`) -> เชื่อมทุกอย่างเข้าหากัน

---

## 🛠 ขั้นตอนการสร้างฟังก์ชันใหม่ (Step-by-Step)

สมมติว่าเราต้องการสร้างฟังก์ชัน **"ดึงข้อมูลเหรียญของ User"** (GetUserCoins) ใน Feature โซนผู้ใช้ (`features/user`) ให้ทำตามลำดับนี้:

### 1. Data Source (คุยกับ SQLite โดยตรง)
📍 **ตำแหน่ง:** `lib/features/<feature_name>/data/datasources/<feature_name>_local_datasource.dart`
* **หน้าที่:** เป็นไฟล์เดียวที่อนุญาตให้มีคำสั่งยิง Database (`insert`, `query`, `delete`, `update`)
```dart
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';

class UserLocalDataSource {
  final DatabaseHelper dbHelper;
  UserLocalDataSource(this.dbHelper);
  
  Future<Database> get db async => await dbHelper.database;

  Future<int> getUserCoins(String userId) async {
    final userDb = await db;
    final result = await userDb.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) {
      return result.first['coin_balance'] as int;
    }
    return 0;
  }
}
```

### 2. Domain Repository (สร้างสัญญา/Interface)
📍 **ตำแหน่ง:** `lib/features/<feature_name>/domain/repositories/<feature_name>_repository.dart`
* **หน้าที่:** ประกาศชื่อฟังก์ชัน (ห้ามมี implementation) เพื่อให้ Layer บนๆ ไม่ต้องรู้จักคำสั่ง SQL หรือ SQLite เลย
```dart
abstract class UserRepository {
  Future<int> getUserCoins(String userId);
}
```

### 3. Data Repository Impl (เชื่อม DataSource เข้ากับ Domain)
📍 **ตำแหน่ง:** `lib/features/<feature_name>/data/repositories/<feature_name>_repository_impl.dart`
* **หน้าที่:** Implement สัญญาณจาก Domain โดยไปดึงค่าจาก Data Source มาแปลงข้อมูลให้อยู่ในรูปแบบ Entity (ถ้ามี)
```dart
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource dataSource;
  UserRepositoryImpl(this.dataSource);

  @override
  Future<int> getUserCoins(String userId) async {
    return await dataSource.getUserCoins(userId);
  }
}
```

### 4. Use Case (เขียนตรรกะรายฟังก์ชัน)
📍 **ตำแหน่ง:** `lib/features/<feature_name>/domain/usecases/get_user_coins.dart`
* **หน้าที่:** แยก 1 คลาสต่อ 1 หน้าที่ ให้เรียกผ่าน `call()` อย่างเดียว
```dart
import '../repositories/user_repository.dart';

class GetUserCoins {
  final UserRepository repository;
  GetUserCoins(this.repository);

  Future<int> call(String userId) async {
    return await repository.getUserCoins(userId);
  }
}
```

### 5. Provider (เรียกผ่านฝั่ง UI)
📍 **ตำแหน่ง:** `lib/features/<feature_name>/presentation/providers/<feature_name>_provider.dart`
* **หน้าที่:** รับหน้าผูก State เข้ากับ Widget ของ Flutter แล้วเรียก GetUserCoins เมื่อ UI ต้องการ
```dart
import 'package:flutter/material.dart';
import '../../domain/usecases/get_user_coins.dart';

class UserProvider extends ChangeNotifier {
  final GetUserCoins getUserCoinsUseCase;
  int currentCoins = 0;

  UserProvider({required this.getUserCoinsUseCase});

  Future<void> fetchCoins(String userId) async {
    currentCoins = await getUserCoinsUseCase(userId);
    notifyListeners(); // สั่งรีเฟรชหน้าจอ
  }
}
```

### 6. Dependency Injection (ต่อสายไฟ)
📍 **ตำแหน่ง:** `lib/main.dart` หรือ `lib/injection_container.dart`
* **หน้าที่:** เอา Class ทุกตัวที่สร้างมาโยงเข้าหากัน
```dart
  final dbHelper = DatabaseHelper();
  final userDataSource = UserLocalDataSource(dbHelper);
  final userRepository = UserRepositoryImpl(userDataSource);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserProvider(
          getUserCoinsUseCase: GetUserCoins(userRepository),
        ),
      ),
    ],
...
```

---

## 🎯 กฎเหล็ก (Do & Don't)
- ❌ **ห้าม** ยิง `db.insert` หรือ `db.query` ในหน้าจอ UI (Widgets) หรือใน UseCase เด็ดขาด! 
- ❌ **ห้าม** นำคลาสจาก `sqflite` ทะลุเข้าไปในโฟลเดอร์ของ `domain` ต้องอยู่แค่โซน `data/datasources` เท่านั้น
- ✅ ทุก Feature ที่ต่างหมวดหมู่กัน ให้แยก Folder `datasources`, `repositories` ให้ชัดเจน (เช่น `timer`, `shop`, `zoo`, `user`)
