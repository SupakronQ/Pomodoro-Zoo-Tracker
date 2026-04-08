import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/category/presentation/widgets/category_card.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  
  // ฟังก์ชันสำหรับเปิด Modal
  void _showCategoryModal({String? initialTitle}) {
    bool isNew = initialTitle == null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // สำคัญ: เพื่อให้ขยายตามคีย์บอร์ด
      backgroundColor: Colors.transparent, // เพื่อให้เห็นขอบโค้งของ Container
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ดันขึ้นเมื่อคีย์บอร์ดมา
        ),
        child: _buildModalContent(isNew, initialTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Add Button
            _buildPageHeader(),
            const SizedBox(height: 32),
            
            const Text(
              "EXISTING ECOSYSTEM",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),

            // รายการ Category
            _buildCategoryItem("Deep Work", Icons.work, 0.75, "3 / 4h"),
            _buildCategoryItem("Learning", Icons.menu_book, 0.9, "1.8 / 2h"),
            _buildCategoryItem("Restoration", Icons.spa, 0.2, "0.2 / 1h"),
            
            const SizedBox(height: 100), // เผื่อพื้นที่ให้ Bottom Nav
          ],
        ),
      ),
    );
  }

  // ส่วนประกอบของ Modal
  Widget _buildModalContent(bool isNew, String? initialTitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow, // สีเขียวอ่อน f8fbf8
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)), // โค้งมนสูง
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNew ? "New Category" : "Edit Category",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (!isNew)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                )
              else
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildLabel("IDENTITY"),
          _buildTextField(isNew ? "" : initialTitle!),
          const SizedBox(height: 24),
          
          _buildLabel("DAILY FOCUS GOAL"),
          _buildGoalSlider(),
          const SizedBox(height: 40),
          
          _buildSaveButton(isNew ? "Create Category" : "Save Changes"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Manage Categories", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
            Text("WORKSPACE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        GestureDetector(
          onTap: () => _showCategoryModal(), // เปิด Modal แบบสร้างใหม่
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, double progress, String stats) {
    return GestureDetector(
      onTap: () => _showCategoryModal(initialTitle: title), // เปิด Modal แบบแก้ไข
      child: CategoryCard(title: title, icon: icon, progress: progress, stats: stats),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1.5)),
  );

  Widget _buildTextField(String value) => TextField(
    controller: TextEditingController(text: value),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: "Category Name",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );

  Widget _buildGoalSlider() => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [Text("Progress"), Text("4.0 Hours", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))],
      ),
      Slider(value: 4, max: 12, onChanged: (v) {}, activeColor: AppColors.primary),
    ],
  );

  Widget _buildSaveButton(String label) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}