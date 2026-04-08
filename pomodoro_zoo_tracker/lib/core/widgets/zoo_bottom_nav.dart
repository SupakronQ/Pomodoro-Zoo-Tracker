// zoo_bottom_nav.dart (อัปเดตแบบซ่อน Label)

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ZooBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ZooBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101F16).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white.withOpacity(0.6),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.timer_outlined, Icons.timer, "FOCUS"),
                  _buildNavItem(1, Icons.category_outlined, Icons.category, "CATEGORY"),
                  _buildNavItem(2, Icons.leaderboard_outlined, Icons.leaderboard, "STATS"),
                  _buildNavItem(3, Icons.pets_outlined, Icons.pets, "ZOO"),
                  // _buildNavItem(4, Icons.settings_outlined, Icons.settings, "SETTINGS"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        
        // --- แก้ไข Padding: ปรับตามสถานะ Active/Inactive ---
        // เมื่อ Inactive (แสดงแค่ไอคอน) ใช้ padding น้อยๆ รอบไอคอน
        // เมื่อ Active (แคปซูล) ใช้ padding ด้านข้างมากกว่าปกติเพื่อให้ดูพรีเมียม
        padding: isActive 
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) 
            : const EdgeInsets.all(12), // padding รอบๆ ไอคอนกลมๆ
        // -----------------------------------------------
        
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        
        // --- แก้ไข Column: เพิ่ม AnimatedSwitcher เพื่อความลื่นไหล ---
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.onSurface : AppColors.secondary,
            ),
            
            // --- แก้ไข: ซ่อน Label เมื่อไม่ Active ---
            // ใช้ AnimatedSwitcher เพื่อให้ตัวหนังสือค่อยๆ ปรากฏขึ้น/หายไป
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label.toUpperCase(),
                        key: ValueKey('label_$index'), // สำคัญสำหรับ AnimatedSwitcher
                        style: TextStyle(
                          fontSize: 11, // เพิ่มขนาดได้นิดหน่อยเพราะพื้นที่เหลือเยอะ
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(), // หายไปเมื่อไม่ Active
            ),
            // -----------------------------------------
          ],
        ),
      ),
    );
  }
}