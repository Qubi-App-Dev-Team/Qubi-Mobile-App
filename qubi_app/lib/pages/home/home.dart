import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubi_app/pages/home/components/qubi_card.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6EEF8),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6EEF8),
        title: Text(
          "My Qubis",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _buildTopButton('assets/icons/Add.svg'),
                const SizedBox(width: 8), // space between buttons
                _buildTopButton('assets/icons/Settings.svg'),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Color(0xFFC7DDF0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // limited-height scrollable list
            SizedBox(height: 10),
            SizedBox(
              height: 325,
              child: ListView(
                children: const [
                  QubiCard(title: "Qubi v1", qubiColor: Color(0xFF66E3C4)),
                  QubiCard(title: "Qubi v1", qubiColor: Color(0xFF9D6CFF)),
                  QubiCard(title: "Qubi v1", qubiColor: Colors.blue),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft, // diagonal start
                  end: Alignment.topRight, // diagonal end
                  colors: [
                    Color(0xFF6525FE), // purple
                    Color(0xFFF25F1C), // orange
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last shake - IBM Hanoi (32 qubits)",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // "Read Report" → RunPage()
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RunPage(),
                            ),
                          );
                        },
                        child: buildGradientButton("Read Report", true),
                      ),
                      const SizedBox(width: 12),

                      // "Skip to Story" (go to story page)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoryPage(),
                            ),
                          );
                        },
                        child: buildGradientButton("Skip to Story", false),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left : 16, right: 16, top: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending Circuit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
                  Text('View all >', style: TextStyle(fontSize: 15, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              width: double.infinity,
              child: SvgPicture.asset(
                'assets/images/circuit1.svg',
                height: 140, // adjust to fit your design
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft, // diagonal start
                  end: Alignment.topRight, // diagonal end
                  colors: [
                    Color(0xFF6525FE), // purple
                    Color(0xFF1A91FC), // blue
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select executor",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExecutorPage(),
                        ),
                      );
                      debugPrint('hello');
                      // TODO: navigate to next page here
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft, // diagonal start
                          end: Alignment.topRight,
                          colors: [
                            Colors.black.withValues(alpha: .20),
                            Color(0xFFF7FAFC).withValues(alpha: .20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "IBM Hanoi (32 qubits)",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildTopButton(String assetPath) {
    return SizedBox(
      height: 38,
      width: 38,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(1),
        child: SvgPicture.asset(
          assetPath,
          color: Color(0xff000000),
          width: 20,
          height: 20,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget buildGradientButton(String label, bool outlined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: outlined ? Border.all(color: Colors.white, width: 1.5) : null,
        color: outlined
            ? Colors.transparent
            : Colors.white.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Text(">", style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText({
    super.key,
    required this.text,
    required this.colors,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
