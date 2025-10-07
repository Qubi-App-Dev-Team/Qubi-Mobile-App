import 'package:flutter/material.dart';

class ExecutorCard extends StatelessWidget {
  final String name; // executor name (e.g., IBM Hanoi)
  final String subtitle; // short description (e.g., qubits, architecture)
  final String details; // extra info (e.g., queue, wait time)
  final bool isActive; // true → active executor (has access)
  final VoidCallback onTap; // callback for main button
  final VoidCallback? onOptionsTap; // optional callback for 3-dot menu

  const ExecutorCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.details,
    required this.isActive,
    required this.onTap,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Card background and border appearance
        color: isActive ? const Color(0xFFF8FAFD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E6ED),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // Full card content layout
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------------
          // HEADER ROW → Executor name + "Online" badge (if active)
          // --------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Executor Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBF8EC),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Online",
                        style: TextStyle(
                          color: Color(0xFF00C88C),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // --------------------------------------------------------------
          // SUBTITLE + DETAILS → architecture info and queue time
          // --------------------------------------------------------------
          const SizedBox(height: 6),
          Text(
            subtitle, // e.g., “32 qubits • Transmon architecture”
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details, // e.g., “Queue: 3 jobs • Est. wait: 2m 30s”
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // --------------------------------------------------------------
          // DIVIDER LINE → separates text section from button section
          // --------------------------------------------------------------
          const Divider(color: Color(0xFFC7DDF0), thickness: 1.5),
          const SizedBox(height: 12),

          // --------------------------------------------------------------
          // BUTTON ROW → “Use this executor” / “Setup Access” + options
          // --------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main action button
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),

                    // ----------------------------------------------------
                    // Gradient + color logic:
                    // - Active → white button (outline only)
                    // - Inactive → gradient background
                    // ----------------------------------------------------
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                      color: isActive
                          ? const Color(0xFFFFFFFF)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC7DDF0),
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        // ------------------------------------------------
                        // Conditional text:
                        // “Use this executor” (active)
                        // “Setup Access” (inactive)
                        // ------------------------------------------------
                        isActive ? "Use this executor" : "Setup Access",
                        style: TextStyle(
                          color: isActive ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------------------
              // SECONDARY BUTTON → 3-dot circle for options (only if active)
              // --------------------------------------------------------------
              if (isActive) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onOptionsTap ?? () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFC7DDF0),
                        width: 1.4,
                      )
                    ),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
