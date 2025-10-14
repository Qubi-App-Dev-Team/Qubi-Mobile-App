import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_section.dart';

//Container component for the individual topics within a chapter (beginner, intermediate, advanced)
class ChapterContentContainer extends StatelessWidget {
  final Chapter chapter; // NEW: so sections can navigate using the chapter model

  const ChapterContentContainer({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        ChapterContentSection(
          chapter: chapter, // pass through
          items: const [
            ChapterContent(title: 'Measurement', description: 'Discover the laws of a single qubit. earn how quantum particles behave when you try to...', progress: 1.0, locked: false),
            ChapterContent(title: 'Entanglement', description: 'Dive into the fascinating world where two particles become linked, so that what...', progress: 0.26, locked: false),
            ChapterContent(title: 'Unlock the rainbow visualizer', description: 'See entanglement in action.', progress: 0.0, locked: false),
            ChapterContent(title: 'Rotation in entanglement', description: 'Understand how quantum gates manipulate qubits, and how these gates combine to...', locked: true),
            ChapterContent(title: 'Measurements in entanglement', description: 'Explore famous algorithms like Grover’s and Shor’s, which show how quantum computers...', locked: true),
            ChapterContent(title: 'Quantum Gates and Circuits', description: 'Build the logic of the quantum world.', locked: true),
            ChapterContent(title: 'Quantum Decoherence and Noise', description: 'Why quantum systems are fragile.', locked: true),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
