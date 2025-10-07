import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/components/round_icon_button.dart';

//Top bar of the all chapters page aligned in a row
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onSettings;

  const TopBar({
    super.key,
    this.onAdd,
    this.onSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.transparent, // fully transparent app bar
        child: Row(
          children: [
            // Logo: give a concrete height so it always renders
            SizedBox(
              height: 35,
                child: Image.asset(
                  'assets/images/qubi_logo.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
            ),

            const Spacer(),

            // Right-side buttons (no functionality yet)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundIconButton(icon: Icons.add, onPressed: onAdd),
                const SizedBox(width: 12),
                RoundIconButton(icon: Icons.settings, onPressed: onSettings),
              ],
            ),
          ],
        ),
      ),
    );
  }
}