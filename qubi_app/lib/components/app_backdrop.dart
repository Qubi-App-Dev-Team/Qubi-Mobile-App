import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBackdrop extends StatelessWidget {
  final Widget child;
  final String assetPath;

  const AppBackdrop({
    super.key,
    required this.child,
    this.assetPath = 'assets/images/light_bg.svg', // Provide filepath for the svg here
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SVG fills the entire screen behind everything
        Positioned.fill(
          child: SvgPicture.asset(
            assetPath,
            fit: BoxFit.cover, // cover to avoid letterboxing
            alignment: Alignment.center,
            // semanticsLabel: 'App background', optional a11y label
          ),
        ),
        // Page content on top
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}