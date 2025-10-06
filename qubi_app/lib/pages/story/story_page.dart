import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final PageController _pageController = PageController();
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
      "subtitle": '''An illustration of X-rays scattering off the valence electrons surrounding ammonia molecules



















      scroll to see''',
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background SVG
          SvgPicture.asset(
            'assets/images/light_bg.svg',
            fit: BoxFit.cover,
          ),

          // Tap detector
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final dx = details.globalPosition.dx;
              if (dx > width / 2) {
                _nextStory();
              } else {
                _previousStory();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.12, // leave room for X + bars
                  ),
                  child: SingleChildScrollView( // <-- FIX for overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          story["title"]!,
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.04),
                          child: Image.asset(
                            story["image"]!,
                            width: double.infinity,
                            height: height * 0.45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        // Subtitle
                        Text(
                          story["subtitle"]!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // X button + Progress bars pinned at top
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // X button
                Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.02,
                    top: height * 0.005,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: width * 0.07,
                    ),
                  ),
                ),

                // Progress bars
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.01,
                  ),
                  child: Row(
                    children: List.generate(
                      _stories.length,
                      (i) => Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.005),
                          height: height * 0.004,
                          decoration: BoxDecoration(
                            color: i <= _currentIndex
                                ? Colors.black
                                : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
