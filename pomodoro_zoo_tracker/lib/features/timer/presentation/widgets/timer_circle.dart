import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';

class ZooTimerDisplay extends StatelessWidget {
  final double progress;      // provider.progress (0.0 - 1.0)
  final String formattedTime; // provider.formattedTime (เช่น "25:00")
  final bool isCompleted;     // provider.isCompleted
  final String phaseLabel;
  final int currentRound;

  const ZooTimerDisplay({
    super.key,
    required this.progress,
    required this.formattedTime,
    required this.isCompleted,
    required this.phaseLabel,
    required this.currentRound,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // ให้รูปสัตว์ลอยออกจากขอบวงกลมได้
        children: [
          // 1. Progress Ring
          SizedBox(
            width: 300,
            height: 300,
            child: CircularProgressIndicator(
              value: isCompleted ? 1.0 : progress, // ถ้าจบแล้วให้เต็มวง
              strokeWidth: 10,
              backgroundColor: AppColors.surfaceVariant, // สี d5e7d9
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.secondary : AppColors.primary, // เปลี่ยนสีเมื่อจบ
              ),
              strokeCap: StrokeCap.round, // ปลายเส้นโค้งมน
            ),
          ),

          // 2. Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // สถานะ: เปลี่ยนจาก FOCUS เป็น COMPLETED เมื่อจบ
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.psychology,
                    color: isCompleted ? AppColors.secondary : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted ? "COMPLETED" : phaseLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // ตัวเลขเวลา
              Text(
                formattedTime,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 84,
                      letterSpacing: -3,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              // รอบการทำงาน
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow, // สี e7f8e9
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Round $currentRound/4",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),

          // 3. Floating Animal Glass Card
          Positioned(
            top: -15,
            right: -15,
            child: _buildAnimalCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101F16).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Glass Effect
          child: Container(
            color: Colors.white.withOpacity(0.4),
            padding: const EdgeInsets.all(14),
            child: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRm8ahumGFysI15RXbJ_V9v6mVp9NXIdwvb3g&s", // เปลี่ยนเป็น Assets ของคุณ
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}