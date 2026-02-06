import 'package:flutter/material.dart';
import 'package:university_app/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WaveContainerWithContent extends StatelessWidget {
  final String title;

  WaveContainerWithContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        width: double.infinity,
        height: 150,
        color: AppColors.selectedNavItemColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pageBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;

    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height * 0.8);
    path.quadraticBezierTo(width * 0.5, height, 0, height * 0.8);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
