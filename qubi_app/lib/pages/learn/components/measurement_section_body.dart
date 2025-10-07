import 'package:flutter/material.dart';

//Demo body of measurement section taken off the Figma to show what a page looks like
class MeasurementSectionBody extends StatelessWidget {
  final VoidCallback? onFeltVibration;
  final VoidCallback? onNoVibration;

  const MeasurementSectionBody({
    super.key,
    this.onFeltVibration,
    this.onNoVibration,
  });

  @override
  Widget build(BuildContext context) {
    // Unified base style (matches your 2nd paragraph)
    const TextStyle baseStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );

    const backgroundGray = Color(0xFFE6EEF8);
    const cardBorder = Color(0xFFD6DEE9);

    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          Center(
            child: Image.asset(
              'assets/images/qubi_ball.png',
              width: size.width * 0.95,
              height: size.height / 3.05,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 1),
          // "Shake it!" (same structure & style)
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: 'Shake it!'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Paragraph 1 (same structure & style)
          RichText(
            text: const TextSpan(
              style: baseStyle,
              children: [
                TextSpan(
                  text:
                      'Imagine you are a scientist presented with a strange sphere called Qubi.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Paragraph 2 (same structure & style, with a bold span)
          RichText(
            text: const TextSpan(
              style: baseStyle,
              children: [
                TextSpan(
                  text:
                      'Something is hidden inside: a mysterious dot that you can’t see just by looking. '
                      'You want to find out where the dot is, but there’s only one way to get information: ',
                ),
                TextSpan(
                  text: 'shake the sphere',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Experiment Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card title (bold span inside same base)
                RichText(
                  text: const TextSpan(
                    style: baseStyle,
                    children: [
                      TextSpan(
                        text: 'Experiment 1: Shake to find the dot!',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card body paragraph (same base)
                RichText(
                  text: const TextSpan(
                    style: baseStyle,
                    children: [
                      TextSpan(
                        text:
                            'Shake the Qubi hard in a straight line by jabbing it in one line until you feel a vibration. '
                            'It should travel in a straight line as you’re shaking — no twisting or arc-ing it!',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons (labels also via RichText + baseStyle)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onFeltVibration ?? () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          side: const BorderSide(color: cardBorder),
                          // We keep text weight consistent via RichText child below.
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: baseStyle,
                            children: [
                              TextSpan(text: 'I felt a vibration!'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onNoVibration ?? () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                          backgroundColor: backgroundGray,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: baseStyle,
                            children: [
                              TextSpan(text: "I didn't feel a vibration"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
