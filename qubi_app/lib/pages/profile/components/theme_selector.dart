import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubi_app/assets/app_colors.dart';

class ThemeSelector extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? label;

  const ThemeSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.label,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  // Local animation trigger for each dot
  int? _tappingIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.richBlack,
              ),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ), // prevents vertical clipping
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(6, (index) {
              final selected = index == widget.selectedIndex;
              return GestureDetector(
                onTapDown: (_) => setState(() => _tappingIndex = index),
                onTapUp: (_) {
                  widget.onSelect(index);
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) setState(() => _tappingIndex = null);
                  });
                },
                onTapCancel: () => setState(() => _tappingIndex = null),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ), // keeps dots from touching edges
                  child: AnimatedScale(
                    scale: _tappingIndex == index || selected ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected ? 1.0 : 0.85,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SvgPicture.asset(
                            'assets/images/themedot${index + 1}${selected ? 'selected' : ''}.svg',
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
