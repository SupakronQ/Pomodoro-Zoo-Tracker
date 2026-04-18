🧩 Sprint Plan (2 สัปดาห์ / 10–12 วันทำงาน)
👥 Team
👨‍💻 Dev A = Timer / Logic
👨‍💻 Dev B = Data / Backend
👨‍🎨 Dev C = UI / UX
🚀 Phase 1: Core (Day 1–4)

เป้าหมาย: Timer ใช้งานได้ + เก็บข้อมูลได้

🕒 Timer System
[A] Timer Core Logic
 สร้าง TimerEntity
 เขียน UseCase: Start / Pause / Reset
 รองรับ Focus / Break
 ระบบ Round (4 รอบ → long break)
 Handle app lifecycle (pause app แล้วเวลายังถูก)

⏱️ 1.5 วัน

[A] Timer Provider (ChangeNotifier)
 สร้าง TimerViewModel
 expose:
currentTime
isRunning
currentMode
round
 notifyListeners()

⏱️ 0.5 วัน

[C] Timer UI
 วงกลม Timer
 ปุ่ม Start / Pause / Reset
 แสดง Mode + Round
 layout minimal (white + green)

⏱️ 1 วัน

[B] SQLite Setup
 setup sqflite
 create database
 migration system

⏱️ 0.5 วัน

[B] Database Tables (Core)
 categories table
 timer_logs table
 coins table

⏱️ 0.5 วัน

[B] Save Timer Session
 เมื่อ timer จบ → insert log
 เก็บ:
duration
category_id
date

⏱️ 0.5 วัน

[C] Category Selector UI
 dropdown / modal
 show category list
 select ก่อน start

⏱️ 0.5 วัน

🎯 Phase 2: Productivity (Day 5–8)

เป้าหมาย: มี Stats + Category + Goals

🗂️ Category Management
[B] Category Repository
 CRUD category
 support:
name
color
type (daily / total)

⏱️ 0.5 วัน

[C] Category UI
 list category
 add / edit / delete
 goal setting UI

⏱️ 1 วัน

📊 Stats System
[B] Stats Logic
 sum duration per category
 group by day/week/month
 calculate percentage

⏱️ 1 วัน

[C] Stats UI
 pie chart
 bar chart
 filter tabs

⏱️ 1 วัน

💰 Coin System
[A] Coin Logic
 1 hour focus = coins
 calculate from logs
 update coin balance

⏱️ 0.5 วัน

[B] Coin Storage
 table coins
 update / read balance

⏱️ 0.5 วัน

[C] Coin UI
 show coin balance (top bar)
 animation ตอนได้ coin

⏱️ 0.5 วัน

🎲 Phase 3: Gacha + Encyclopedia (Day 9–12)

เป้าหมาย: แอป “มีของเล่น” (engagement)

🐾 Animal System
[B] Animal Database
 animals table:
id
name
rarity
image
 user_animals table (collection)

⏱️ 1 วัน

[C] Animal Encyclopedia UI
 grid layout
 locked (silhouette)
 unlocked (show image)
 progress (12/50)

⏱️ 1 วัน

[C] Animal Detail Page
 image
 name
 description
 rarity

⏱️ 0.5 วัน

🎲 Gacha System
[B] Gacha Logic
 random draw
 rarity system:
Common 70%
Rare 25%
Epic 5%
 duplicate handling (convert to coins)

⏱️ 1 วัน

[A] Gacha Provider
 trigger draw
 handle state (loading/result)

⏱️ 0.5 วัน

[C] Gacha UI
 draw button
 animation reveal
 result popup

⏱️ 1 วัน

🧾 Optional (ถ้ามีเวลา)
[B] History Logs
 query logs
 filter

⏱️ 0.5 วัน

[C] History UI
 list view
 filter UI

⏱️ 0.5 วัน

📊 สรุปเวลา (รวม)
คน	งาน	เวลา
Dev A	Timer + Provider + Coin + Gacha state	~3–4 วัน
Dev B	DB + Repository + Stats + Gacha	~4–5 วัน
Dev C	UI ทั้งหมด	~5–6 วัน

👉 ทำ parallel → รวม 10–12 วัน

🔥 ลำดับทำงาน (สำคัญมาก)
Timer ต้องเสร็จก่อน (Day 1–3)
DB ต้องพร้อม (Day 2–4)
Stats ทำหลังมี data
Gacha ทำท้ายสุด
💡 Pro Tips
ใช้ branch แยก feature:
feature/timer
feature/stats
feature/gacha
daily merge กัน (กัน code พัง)
define model ให้ชัดก่อนเริ่ม (ลด refactor)
