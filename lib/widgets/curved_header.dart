import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final Widget child;
  final double height;

  const CurvedHeader({
    super.key,
    required this.child,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedClipper(),
      child: Container(
        color: const Color(0xFFF9183E),
        height: height,
        width: double.infinity,
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}