import 'package:flutter/material.dart';

/// A scrollable container for chapter cards/tiles.
/// - Renders a faint top divider to separate from the transparent top bar
/// - Starts below the app bar (assumes extendBodyBehindAppBar: true)
/// - Shows a big bold "Learn Quantum" header at top-left

class AllChaptersContainer extends StatelessWidget {
  /// Widgets representing individual chapters (e.g., ChapterInfo).
  final List<Widget> children;

  /// Extra spacing between the app bar bottom and the pane content.
  final double contentTopSpacing;

  /// Whether the Scaffold uses extendBodyBehindAppBar (default: true in your app).
  /// If set to false, the pane won't add top padding for the status/app bar.
  final bool extendBodyBehindAppBar;

  const AllChaptersContainer({
    super.key,
    required this.children,
    this.contentTopSpacing = 12.0,
    this.extendBodyBehindAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate how much to nudge content down so it starts below the top bar.
    final media = MediaQuery.of(context);
    final double topInset = extendBodyBehindAppBar
        ? (media.padding.top + kToolbarHeight - 40) // status bar + app bar
        : 0.0;

    return Padding(
      // The pane itself starts at the bottom of the app bar
      padding: EdgeInsets.only(top: topInset),
      child: Column(
        children: [
          // Faint black line for separation from the top bar
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),

          // Make the chapters area scrollable
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Some breathing room before the header content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, contentTopSpacing, 16, 8),
                    child: const Text(
                      'Learn Quantum',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Your future ChapterInfo widgets
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: children.length,
                    itemBuilder: (context, i) => children[i],
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
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