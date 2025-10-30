import 'package:flutter/material.dart';

class SectionPageNavBar extends StatelessWidget {
  final int currentPage;     // 1-based
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final Color backgroundColor;

  const SectionPageNavBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
    this.backgroundColor = const Color(0xFFE6EEF8), // UI stays transparent by default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 72,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onPrev, // parent ensures bounds (no-op if at first page)
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_left, size: 28, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(text: '$currentPage'),
                const TextSpan(text: '/'),
                TextSpan(text: '$totalPages'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onNext, // parent ensures bounds (no-op if at last page)
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_right, size: 28, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
