import 'package:flutter/material.dart';

class SectionPageNavBar extends StatelessWidget {
  final int currentPage;     // 1-based
  final int totalPages;
  final VoidCallback? onPrev; // optional; keep null for now
  final VoidCallback? onNext; // optional; keep null for now
  final Color backgroundColor;

  const SectionPageNavBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
    this.backgroundColor = const Color(0xFFE6EEF8), // matches your app background
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 72,
      color: Colors.transparent, // fully see-through
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onPrev ?? () {},
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
            onTap: onNext ?? () {},
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
