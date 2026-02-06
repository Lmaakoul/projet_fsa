import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomCurvedNavigationBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const CustomCurvedNavigationBar({
    super.key,
    required this.index,
    required this.onTap,
    required Color backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: index,
      height: 48.0,
      color: const Color(0xFF94B4C1),
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: const Color(0xFF547792),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) => onTap(index),
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.qr_code_scanner, size: 30, color: Colors.white),
        Icon(Icons.description, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
      ],
    );
  }
}
