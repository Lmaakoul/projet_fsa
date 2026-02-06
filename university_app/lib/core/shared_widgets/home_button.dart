import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // تأكد من استيراد lucide_icons

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget screen; // الوجهة التي سينتقل لها الزر

  const HomeButton({
    super.key,
    required this.icon,
    required this.title,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container( // إضافة خلفية للأيقونة كما في التصاميم الأخرى (اختياري)
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(17, 58, 71, 0.1), // لون خلفية خفيف
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color.fromRGBO(17, 58, 71, 1)), // لون الأيقونة
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500, // تغيير الوزن قليلاً
          color: Color.fromRGBO(17, 58, 71, 1), // لون النص
        ),
      ),
      trailing: const Icon( // إضافة سهم صغير
        LucideIcons.chevronRight,
        size: 18,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}