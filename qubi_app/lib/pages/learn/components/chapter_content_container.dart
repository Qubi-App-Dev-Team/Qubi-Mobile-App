import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/components/chapter_difficulty_section.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';

//Container component for the individual topics within a chapter (beginner, intermediate, advanced)
class ChapterContentContainer extends StatelessWidget {
  const ChapterContentContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ChapterDifficultySection(
          difficulty: 'beginner',
          completion: 0.42,
          isFirst: true,
          isLast: false,
          items: [
            ChapterContent(title: 'Measurement', description: 'Discover the laws of a single qubit. Learn how quantum particles behave when you try to...', progress: 1.0, locked: false),
            ChapterContent(title: 'Entanglement', description: 'Dive into the fascinating world where two particles become linked, so that what...', progress: 0.3, locked: false),
            ChapterContent(title: 'Unlock the rainbow visualizer', description: 'See entanglement in action.', progress: 0.0, locked: false),
          ]
        ),
        ChapterDifficultySection(
          difficulty: 'intermediate',
          completion: 0.0,
          isFirst: false,
          isLast: false,
          items: [
            ChapterContent(title: 'Rotation in entanglement', description: 'Understand how quantum gates manipulate qubits, and how these gates combine to...', locked: true),
            ChapterContent(title: 'Measurements in entanglement', description: 'Explore famous algorithms like Grover’s and Shor’s, which show how quantum computers...', locked: true),
          ],
        ),
        ChapterDifficultySection(
          difficulty: 'advanced',
          completion: 0.0,
          isFirst: false,
          isLast: true, // no connector below last
          items: [
            ChapterContent(title: 'Entanglement & Bell', description: 'Build the logic of the quantum world.', locked: true),
            ChapterContent(title: 'Quantum Decoherence and Noise', description: 'Why quantum systems are fragile.', locked: true),
          ]
        ),
      ],
    );
  }
}