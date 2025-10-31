// import 'package:flutter/material.dart';
// import 'package:qubi_app/pages/learn/models/chapter_content.dart';
// import 'package:qubi_app/pages/learn/models/chapter.dart';
// import 'package:qubi_app/pages/learn/components/chapter_content_box.dart';
// import 'package:qubi_app/pages/learn/pages/section_content_page.dart';
// import 'package:qubi_app/pages/learn/models/section_routes.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// //Widget which organizes all of the 3 sections of a given chapters page as well as their interactions
// //Interactions are scrolling, dropdown, and line extensions from Figma
// class ChapterDifficultySection extends StatefulWidget {
//   final Chapter chapter;
//   final String difficulty;    // 'beginner' | 'intermediate' | 'advanced'
//   final double completion;    // 0..1 (overall completion text on the row)
//   final bool isFirst;
//   final bool isLast;

//   /// The three content items under this difficulty
//   final List<ChapterContent> items;

//   const ChapterDifficultySection({
//     super.key,
//     required this.chapter,
//     required this.difficulty,
//     required this.completion,
//     required this.items,
//     this.isFirst = false,
//     this.isLast = false,
//   });

//   @override
//   State<ChapterDifficultySection> createState() => _ChapterDifficultySectionState();
// }

// class _ChapterDifficultySectionState extends State<ChapterDifficultySection> {
//   bool _expanded = false;

//   // Colors & sizes
//   static const _connectorColor = Color(0xFFB9C1CC);
//   static const _chipGrey       = Color(0xFFF7FAFC); // standard grey icon box 
//   static const _bulletOuter    = Color(0xFFB9C1CC);
//   static const _bulletInner    = Color(0xFF23D5AF);

//   static const double _hPadding   = 16.0;
//   static const double _rowHeight  = 48.0;
//   static const double _bulletSize = 14.0;
//   static const double _iconBox    = 30.0;
//   static const double _iconSize   = 20.0;

//   // Consistent gaps around bullets for the connector stubs
//   static const double _gapBelowBullet = 4.0; // start a few px below current bullet
//   static const double _gapAboveBullet = 4.0; // end a few px above next bullet

//   String get _difficultyLabel {
//     final s = widget.difficulty;
//     return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
//   }

//   String get _completedText =>
//       '${(widget.completion.clamp(0.0, 1.0) * 100).round()}% completed';

//   @override
//   Widget build(BuildContext context) {
//     // The Stack sits inside a horizontal Padding(_hPadding), so compute X from that origin.
//     final double connectorX = (_bulletSize / 2) - 1; // 2px line centered on bullet

//     // Bullet vertical metrics within the row
//     final double bulletTop    = (_rowHeight - _bulletSize) / 2;
//     final double bulletBottom = bulletTop + _bulletSize;

//     final contentList = Padding(
//       padding: EdgeInsets.only(left: (_bulletSize + 12) + 24, top: 8, bottom: 8),
//       child: Column(
//         children: [
//           for (int i = 0; i < widget.items.length; i++) ...[
//             InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () {
//                 final item = widget.items[i];
//                 if (item.locked) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("You haven't unlocked this section yet!"),
//                       behavior: SnackBarBehavior.floating,
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                   return;
//                 }
//                 // ✅ Navigate using Chapter + ChapterContent + optional custom children
//                   final key = item.title.toLowerCase().replaceAll(' ', '_');

//                   final builder = sectionRoutes[key];
//                   final children = builder != null
//                       ? builder(widget.chapter, item)
//                       : const [
//                         SizedBox(height: 540)
//                       ];

//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => SectionContentPage(
//                         chapter: widget.chapter,
//                         content: item,
//                         children: children,
//                       ),
//                     ),
//                   );
//               },
//               child: ChapterContentBox(
//                 title: widget.items[i].title,
//                 description: widget.items[i].description,
//                 progress: widget.items[i].progress,
//                 locked: widget.items[i].locked,
//               ),
//             ),
//             if (i != widget.items.length - 1) const SizedBox(height: 12),
//           ],
//         ],
//       ),
//     );

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: _hPadding),
//       child: Column(
//         children: [
//           // ===== One difficulty section (with its own connectors drawn in a Stack) =====
//           Stack(
//             children: [
//               // Top connector: from top edge to just above current bullet (omit for the first)
//               if (!widget.isFirst)
//                 Positioned(
//                   left: connectorX,
//                   top: 0,
//                   child: Container(
//                     width: 2,
//                     height: (bulletTop - _gapAboveBullet).clamp(0.0, double.infinity),
//                     color: _connectorColor,
//                   ),
//                 ),

//               // Bottom connector: from just below current bullet to the bottom of this block.
//               // For all sections (including the last/advanced), extend to bottom: 0 so there is
//               // no unintended gap to the next block (the Done row follows immediately).
//               Positioned(
//                 left: connectorX,
//                 top: bulletBottom + _gapBelowBullet,
//                 bottom: 0,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   curve: Curves.easeInOut,
//                   width: 2,
//                   color: _connectorColor,
//                 ),
//               ),

//               // Foreground: header row + expanding content
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header row
//                   SizedBox(
//                     height: _rowHeight,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Bullet
//                         _Bullet(
//                           size: _bulletSize,
//                           outerColor: _bulletOuter,
//                           innerColor: _bulletInner,
//                         ),
//                         const SizedBox(width: 12),

//                         // Difficulty icon in grey rounded box
//                         Container(
//                           width: _iconBox,
//                           height: _iconBox,
//                           decoration: BoxDecoration(
//                             color: _chipGrey,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           alignment: Alignment.center,
//                           child: SvgPicture.asset(
//                             'assets/images/${widget.difficulty.toLowerCase()}_icon.svg',
//                             width: _iconSize,
//                             height: _iconSize,
//                             errorBuilder: (c, e, s) =>
//                                 const Icon(Icons.error_outline, size: 18, color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 10),

//                         // Difficulty label
//                         Text(
//                           _difficultyLabel,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),

//                         const Spacer(),

//                         // Completion text
//                         Text(
//                           _completedText,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(width: 8),

//                         // Toggle caret
//                         InkWell(
//                           borderRadius: BorderRadius.circular(8),
//                           onTap: () => setState(() => _expanded = !_expanded),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
//                             child: Icon(
//                               _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                               size: 26,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // EXPANDED CONTENT: 3 content boxes
//                   AnimatedCrossFade(
//                     firstChild: const SizedBox(height: 0),
//                     secondChild: contentList, 
//                     crossFadeState:
//                         _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//                     duration: const Duration(milliseconds: 250),
//                     sizeCurve: Curves.easeInOut,
//                   ),

//                   // A small, consistent gap after each section block
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ],
//           ),

//           // ===== DONE row only after the last (advanced) section =====
//           if (widget.isLast) _DoneRow(
//             bulletSize: _bulletSize,
//             connectorColor: _connectorColor,
//             chipGrey: _chipGrey,
//             bulletOuter: _bulletOuter,
//             bulletInner: _bulletInner,
//             rowHeight: _rowHeight,
//             gapAboveBullet: _gapAboveBullet,
//             gapBelowBullet: _gapBelowBullet,
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Small reusable bullet (grey outer + aquamarine inner)
// class _Bullet extends StatelessWidget {
//   final double size;
//   final Color outerColor;
//   final Color innerColor;

//   const _Bullet({
//     required this.size,
//     required this.outerColor,
//     required this.innerColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: outerColor,
//             ),
//           ),
//           Container(
//             width: size * 0.54,
//             height: size * 0.54,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: innerColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// The final "Done!" header that appears AFTER the last difficulty section.
// /// It draws ONLY a TOP connector stub (no bottom tail), so there’s no
// /// unwanted line extending below. The Advanced section’s bottom connector
// /// (above) ends exactly at this row’s top, so there is no gap.
// class _DoneRow extends StatelessWidget {
//   final double bulletSize;
//   final Color connectorColor;
//   final Color chipGrey;
//   final Color bulletOuter;
//   final Color bulletInner;
//   final double rowHeight;
//   final double gapAboveBullet;
//   final double gapBelowBullet; // kept for symmetry, not used here

//   const _DoneRow({
//     required this.bulletSize,
//     required this.connectorColor,
//     required this.chipGrey,
//     required this.bulletOuter,
//     required this.bulletInner,
//     required this.rowHeight,
//     required this.gapAboveBullet,
//     required this.gapBelowBullet,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Parent already applied horizontal padding. Compute X in that coordinate space.
//     final double connectorX = (bulletSize / 2) - 1;
//     final double bulletTop = (rowHeight - bulletSize) / 2;

//     return Stack(
//       children: [
//         // Top stub: from block top to just above the Done bullet
//         Positioned(
//           left: connectorX,
//           top: 0,
//           child: Container(
//             width: 2,
//             height: (bulletTop - gapAboveBullet).clamp(0.0, double.infinity),
//             color: connectorColor,
//           ),
//         ),

//         // Foreground row (no extra padding; aligns with the sections above)
//         SizedBox(
//           height: rowHeight,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               _Bullet(
//                 size: bulletSize,
//                 outerColor: bulletOuter,
//                 innerColor: bulletInner,
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: chipGrey,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(Icons.check, size: 25, color: Colors.green),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Done!',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const Spacer(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
