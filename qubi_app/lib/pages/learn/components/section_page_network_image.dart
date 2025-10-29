import 'package:flutter/material.dart';

class SectionPageNetworkImage extends StatefulWidget {
  final String url;

  /// Optional clamps to avoid extreme letterboxing if you want a floor/ceiling
  /// for super-wide or super-tall images. Set both to null to allow any ratio.
  final double? minAspectRatio; // e.g. 3/4
  final double? maxAspectRatio; // e.g. 16/9

  /// While loading (before intrinsic size is known), we can use this fallback ratio.
  final double fallbackAspectRatio; // e.g. 16/9 or 4/3

  /// How the image should fit inside the aspect box. 'contain' avoids cropping.
  final BoxFit fit;

  const SectionPageNetworkImage({
    super.key,
    required this.url,
    this.minAspectRatio,
    this.maxAspectRatio,
    this.fallbackAspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
  });

  @override
  State<SectionPageNetworkImage> createState() => _SectionPageNetworkImageState();
}

class _SectionPageNetworkImageState extends State<SectionPageNetworkImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _aspectRatio; // width / height

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant SectionPageNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeStream();
      _aspectRatio = null;
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = NetworkImage(widget.url);
    _stream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((ImageInfo info, bool _) {
      final width = info.image.width.toDouble();
      final height = info.image.height.toDouble();
      if (height > 0) {
        setState(() {
          _aspectRatio = width / height;
        });
      }
    }, onError: (error, stack) {
      // On error, keep fallback ratio and still show an error icon.
      setState(() {
        _aspectRatio = widget.fallbackAspectRatio;
      });
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    _disposeStream();
    super.dispose();
  }

  void _disposeStream() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double ratio = _aspectRatio ?? widget.fallbackAspectRatio;

    // Optionally clamp the ratio to avoid extreme heights
    if (widget.minAspectRatio != null) {
      ratio = ratio < widget.minAspectRatio! ? widget.minAspectRatio! : ratio;
    }
    if (widget.maxAspectRatio != null) {
      ratio = ratio > widget.maxAspectRatio! ? widget.maxAspectRatio! : ratio;
    }

    return AspectRatio(
      aspectRatio: ratio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.url,
          fit: widget.fit, // default BoxFit.contain to avoid cropping
          // Optional: add gapless playback to avoid flicker on rebuilds
          gaplessPlayback: true,
          errorBuilder: (c, e, s) => const Center(
            child: Icon(Icons.broken_image, size: 28, color: Colors.black26),
          ),
        ),
      ),
    );
  }
}
