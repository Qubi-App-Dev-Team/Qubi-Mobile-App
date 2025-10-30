import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// components/app_backdrop.dart
class AppBackdrop extends StatelessWidget {
  final Widget? child;
  final String assetPath;

  const AppBackdrop({
    super.key,
    this.child,
    this.assetPath = 'assets/images/light_bg.svg',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}
