import 'package:flutter/material.dart';

//Round button for header of all chapters file

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size; // diameter of the circle
  final double iconSize;

  const RoundIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 36,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1.5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}