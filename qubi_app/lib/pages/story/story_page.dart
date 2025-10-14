import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//stateful widget means it can change based on state
//so in this case the content displayed changes based on what story we are on
class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final PageController _pageController = PageController();
  //what story we are looking at
  int _currentIndex = 0;

  // Local stories
  final List<Map<String, String>> _stories = [
    {
      "title": "In an Ion Trap, atoms are levitated in mid-air!",
      "subtitle": "Here's a picture of a single Ion in an Ion Trap. (Look closely!)",
      "image": "assets/images/story1.png"
    },
    {
      "title": "And here’s an image of multiple Cesium atoms strung in a line",
      "subtitle": "That’s how IonQ sets up their quantum computer - it’s 36 of these in a line!",
      "image": "assets/images/story2.png"
    },
    {
      "title": "Watch a single electron move during a chemical reaction for first time ever!",
      "subtitle": "An illustration of X-rays scattering off the valence electrons surrounding ammonia molecules",
      "image": "assets/images/story3.png"
    },
  ];

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // SVG background
          SvgPicture.asset(
            'assets/images/light_bg.svg',
            fit: BoxFit.cover,
          ),

          // Tap detector (captures whole screen taps)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              final dx = details.globalPosition.dx;

              // Tap right side → next
              if (dx > width / 2) {
                _nextStory();
              } else {
                // Tap left side → previous
                _previousStory();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(), // disable swipe
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bars
                      Row(
                        children: List.generate(
                          _stories.length,
                          (i) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 3,
                              decoration: BoxDecoration(
                                color: i <= _currentIndex
                                    ? Colors.black
                                    : Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Close button (does nothing yet)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        story["title"]!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          story["image"]!,
                          width: double.infinity,
                          height: 400,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        story["subtitle"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
