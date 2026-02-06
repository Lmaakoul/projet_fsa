// المسار: lib/features/3_professor_role/prof/screen/magic_shape_button.dart
// (الكود المعدل)

import 'package:flutter/material.dart';
// تأكد من جلب الألوان من ملف الثيم أو عرفها هنا
// import 'package:university_app/core/theme/app_colors.dart';

class MagicShapeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MagicShapeButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- ✅ جلب عرض الشاشة ---
    final screenWidth = MediaQuery.of(context).size.width;
    // تحديد العرض النسبي للزر (مثلاً 40% من عرض الشاشة مع مسافة بيناتهم)
    final buttonWidth = screenWidth * 0.4;
    // تحديد الـ Padding بناءً على العرض
    final double paddingValue = screenWidth > 600 ? 35 : 25; // بادينغ أكبر للشاشات الكبيرة
    // تحديد حجم الأيقونة
    final double iconSize = screenWidth > 600 ? 55 : 45;
    // تحديد حجم الخط
    final double fontSize = screenWidth > 600 ? 17 : 15;
    // -------------------------

    // --- ⛔️ تم حذف Expanded ---
    return GestureDetector( // كنخليو GestureDetector
      onTap: onTap,
      child: Container(
        // --- ✅ تحديد العرض والارتفاع ---
        width: buttonWidth,
        height: buttonWidth * 1.1, // نجعل الارتفاع متناسباً مع العرض
        // -----------------------------
        margin: const EdgeInsets.symmetric(horizontal: 5),
        // --- ✅ Padding ديناميكي ---
        padding: EdgeInsets.all(paddingValue),
        // -------------------------
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15), // زيادة الراديوس قليلاً
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- ✅ حجم الأيقونة ديناميكي ---
            Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.onPrimaryContainer /*AppColors.selectedNavItemColor*/), // استخدام لون متناسق مع الخلفية
            // ---------------------------
            const SizedBox(height: 15), // تقليل المسافة
            Text(
              title,
              textAlign: TextAlign.center,
              // --- ✅ حجم الخط ديناميكي ---
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer, // استخدام لون متناسق
              ),
              // -------------------------
            ),
          ],
        ),
      ),
    );
  }
}