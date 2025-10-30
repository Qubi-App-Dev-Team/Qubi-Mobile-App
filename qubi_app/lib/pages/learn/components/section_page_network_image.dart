import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SectionPageNetworkImage extends StatelessWidget {
  final String url;

  const SectionPageNetworkImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size.width * 0.95,
        height: size.height / 3.05,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => const SizedBox.shrink(),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }
}
