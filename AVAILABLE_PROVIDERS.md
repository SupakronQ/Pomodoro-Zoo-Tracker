<!-- 
======================================================================
📜 AI / CONTRIBUTOR GUIDELINES FOR UPDATING THIS FILE
======================================================================
[NOTE: DO NOT REMOVE THIS BLOCK]

เวลาที่ AI หรือผู้ดูแลทำการอัปเดตไฟล์ `AVAILABLE_PROVIDERS.md` 
ให้ยึดกฎเกณฑ์ (Format) ในการเขียนดังต่อไปนี้อย่างเคร่งครัด:

1. เป้าหมาย (Goal):
   - ไฟล์นี้เขียนให้ "Frontend Developers" อ่านเป็นหลัก
   - ห้ามลงรายละเอียดถึง Database, SQLite, Repository, DataSource ในชั้นลึก
   - เน้นที่ตัวแปร State ที่ปั้นสำเร็จรูปแล้ว และชุดคำสั่งที่ UI พร้อมกดเรียกใช้เท่านั้น

2. โครงสร้างของ 1 หมวดหมู่ (Structure per Provider):
   - หัวข้อ `## <Icon> <ลำดับ>. <ProviderName>`
   - `**หน้าที่:**` ควบรวมความหมายแบบสั้นๆ ว่าไว้จัดการ state ของอะไร
   - `**วิธีกำหนดใน UI:**` ตัวอย่างโค้ดเรียกใช้ เช่น `context.read<X>()`
   - `### ค่า State ที่ดึงไปวาดบนหน้าจอได้ (Properties)`
     - ใช้ Bullet Point
     - ระบุ Type ไว้ในวงเล็บเสมอ เช่น `userName (String)`
     - อธิบายการนำไปผูกหน้าจอ
   - `### สั่งงานอะไรได้บ้าง (Methods)`
     - ตัวชื่อฟังก์ชัน ()
     - รับ Parameters อะไรบ้าง
     - ทริกเกอร์ให้ข้อมูลตัวไหนเปลี่ยน เพื่อให้ UI ทราบ
   - `### ตัวอย่างการใช้งาน (Example Usage)`
     - แทรกโค้ดตัวอย่างเพื่อให้ Frontend นักพัฒนาคัดลอกไปทำความเข้าใจได้ทันที

3. ภาษาและสไตล์ (Tone):
   - ภาษากระชับ เป็นมิตร
======================================================================
-->
# 📱 Available Providers Guide (For Frontend Developers)

เอกสารสำหรับ Frontend Developers เพื่อดูภาพรวม "Provider" ทั้งหมดที่มีในโปรเจกต์ ซึ่งเป็นจุดสำคัญในการเชื่อมต่อหน้า UI เข้ากับชั้นข้อมูล (Data/State) 

🚨 **กฎสำคัญของโปรเจกต์:** Frontend **ห้าม** ยิงข้อมูลต่อตรงไปที่ Repository หรือ DataSource เด็ดขาด ให้ใช้ตัวแปรและฟังก์ชันที่อยู่ใน Providers เท่านั้น เพื่อให้หน้าจอรับทราบเมื่อมีการ Update ข้อมูลและสามารถ Refresh UI กลับได้ทันที

---

## ⏱ 1. TimerProvider
**หน้าที่:** ดูแล State ตอนจับเวลา และยิงคำสั่งเริ่ม/หยุด/รีเซ็ต และบันทึกเวลา 
**วิธีกำหนดใน UI:** `context.read<TimerProvider>()` เพื่อสั่งงาน หรือ `context.watch<TimerProvider>()` เพื่อตามอ่านค่า 

### ค่า State ที่ดึงไปวาดบนหน้าจอได้ (Properties)
- `remainingSeconds` (int): เวลาที่เหลืออยู่เป็นวินาที
- `formattedTime` (String): เวลาเพื่อแสดงผล เช่น `"25:00"`
- `isRunning` (bool): ตอนนี้เวลาเดินอยู่มั้ย (เอาไปกำหนดปุ่ม Pause/Play)
- `isCompleted` (bool): จบเซสชันแล้วหรือยัง
- `progress` (double): ความคืบหน้า 0.0 - 1.0 (เอาไปใช้วาดวงกลม/หลอดเวลา)
- `selectedCategoryId` (String?): ส่งไอดีของหมวดหมู่มารอฟิกไว้ก่อนกดจับเวลาได้

### สั่งงานอะไรได้บ้าง (Methods)
- `start()` : สั่งเริ่มจับเวลา 
- `pause()` : สั่งหยุดเวลาชั่วคราว
- `reset()` : กดรีเซ็ตเวลาทิ้ง ถือว่าล้มเลิก

*(เบื้องหลัง: เมื่อกดนับถอยหลังถึง 0 ระบบจะจัดการดึง `selectedCategoryId` และระยะเวลา ไปทำการเซฟลง Log ให้เองแบบอัตโนมัติ UI ไม่ต้องพิมพ์โค้ดสั่งเซฟใดๆ)*

### ตัวอย่างการใช้งาน (Example Usage)
```dart
Widget build(BuildContext context) {
  // อ่านค่า State ผ่าน watch() (เมื่อ State เปลี่ยน หน้าจอนี้จะ Refresh อัตโนมัติ)
  final timerState = context.watch<TimerProvider>();

  return Column(
    children: [
      Text('เวลาที่เหลือ: \${timerState.formattedTime}'), // อัปเดตทุก 1 วินาที
      
      ElevatedButton(
        // สั่งทำงาน โดยใช้ read() เพื่อไม่ให้ปุ่ม Refresh ตัวเองตลอดเวลา
        onPressed: () {
          if (timerState.isRunning) {
            context.read<TimerProvider>().pause();
          } else {
            context.read<TimerProvider>().start();
          }
        },
        child: Text(timerState.isRunning ? 'Pause' : 'Start'),
      )
    ],
  );
}
```

---

## 🗂 2. CategoryProvider
**หน้าที่:** ส่งรายการหมวดหมู่มาให้เลือกโหลด และใช้สร้าง ทิ้งหมวดหมู่เก่าทิ้ง โดยอัปเดต State ต่อเนื่องทันที

### ค่า State ที่ดึงไปวาดบนหน้าจอได้ (Properties)
- `categories` (List<CategoryEntity>): ลิสต์ที่มีข้อมูลของหมวดหมู่ทั้งหมดในระบบ นำมา `ListView.builder` วาดต่อได้เลย
- `isLoading` (bool): เช็คว่ากำลังดึงข้อมูลอยู่หรือไม่ (ขึ้น Loading spinner ได้)

### สั่งงานอะไรได้บ้าง (Methods)
- `loadCategories({String? userId})` 
  - สั่งดึงข้อมูลหมวดหมู่ทั้งหมด โหลดเสร็จลิสต์ในหน้าจอที่ watch ไว้จะอัปเดต
- `createCategory(CategoryEntity category)`
  - สั่งสร้างหมวดหมู่ใหม่ เช่นตอนกรอกฟอร์มตั้งชื่อและเลือกสีใน UI 
- `updateCategory(CategoryEntity category)`
  - โยน Model ตัวเดิมที่เปลี่ยนชื่อหรือเปลี่ยนสีมาให้ ค่าบน UI ทุกจุดจะเปลี่ยนตาม
- `deleteCategory(String id, {String? currentUserId})`
  - สั่งลบหมวดหมู่ทิ้งไป

### ตัวอย่างการใช้งาน (Example Usage)
```dart
Widget build(BuildContext context) {
  final catState = context.watch<CategoryProvider>();

  // แสดง Loading ถ้าข้อมูลกำลังวิ่งมา
  if (catState.isLoading) {
    return const CircularProgressIndicator();
  }

  return Column(
    children: [
      // ลิสต์รายการหมวดหมู่ 
      Expanded(
        child: ListView.builder(
          itemCount: catState.categories.length,
          itemBuilder: (context, index) {
            final cat = catState.categories[index];
            return ListTile(
              title: Text(cat.name),
              // สมมติในระบบมีปลั๊กอิน HexColor แปลง String เป็นสี
              leading: Icon(Icons.circle, color: HexColor(cat.colorHex)), 
            );
          },
        ),
      ),
      
      // ปุ่มสร้างหมวดหมู่ใหม่
      ElevatedButton(
        onPressed: () async {
          final newCat = const CategoryEntity(id: '', name: 'อ่านหนังสือ', colorHex: '#FFAA00');
          
          // สั่ง Create ปุ๊ป Provider จะโหลดข้อมูลใหม่ให้อัตโนมัติและ Refresh หน้าจอนี้ให้เอง
          await context.read<CategoryProvider>().createCategory(newCat);
        },
        child: const Text('Add Category'),
      ),
    ],
  );
}
```
