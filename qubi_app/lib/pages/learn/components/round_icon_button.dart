import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoundIconButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset; // <— new field
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const RoundIconButton({
    super.key,
    this.icon,
    this.svgAsset,
    this.onPressed,
    this.size = 40,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black87,
  }) : assert(icon != null || svgAsset != null,
         'Either icon or svgAsset must be provided.');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: svgAsset != null
              ? SvgPicture.asset(
                  svgAsset!,
                  width: size * 0.5,
                  height: size * 0.5,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Icon(icon, size: size * 0.5, color: iconColor),
        ),
      ),
    );
  }
}
