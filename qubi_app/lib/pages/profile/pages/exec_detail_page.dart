import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_colors.dart';
import 'package:qubi_app/pages/story/story_page.dart';

class ExecDetailPage extends StatelessWidget {
  final String name;
  final String status;
  final String time;

  const ExecDetailPage({
    super.key,
    required this.name,
    required this.status,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bool sent = status.toLowerCase() == "sent";
    final Color badgeColor = sent ? AppColors.ionGreen : AppColors.emberOrange;

    return Scaffold(
      backgroundColor: AppColors.saltWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.saltWhite,
        centerTitle: true,
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.richBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.richBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.memory_rounded,
                    color: AppColors.electricIndigo,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filler Section
            const Text(
              "Run Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.richBlack,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Text(
                "• Backend: Superconducting\n"
                "• Shots: 1024\n"
                "• Duration: 2.3s\n"
                "• Qubits used: 5\n\n"
                "Lorem ipsum filler description about this run. "
                "Once backend data is integrated, this section will show "
                "real-time metrics and circuit parameters.",
                style: TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoryPage()),
                  );
                },
                label: const Text(
                  "See the story of this run",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
