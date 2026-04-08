import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // เรียกใช้ไฟล์สีที่สร้างไว้

class ZooHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int coins;
  final VoidCallback? onCoinTap;
  final bool showBackButton;

  const ZooHeader({
    super.key,
    required this.title,
    this.coins = 0,
    this.onCoinTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0, // ป้องกันสีเปลี่ยนเมื่อ scroll
      automaticallyImplyLeading: false, // จัดการปุ่ม back เอง
      titleSpacing: 20,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ส่วนที่ 1: Icon + Title
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.primary,
                )
              else
                const Icon(
                  Icons.local_florist, // แทน potted_plant ในดีไซน์
                  color: AppColors.primary,
                  size: 24,
                ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans', // ตามดีไซน์ HTML
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // ส่วนที่ 2: Coin Pill Button
          GestureDetector(
            onTap: onCoinTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$coins Coins',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // เส้นประดับด้านล่างบางๆ ตาม HTML
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.primary.withOpacity(0.05),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}