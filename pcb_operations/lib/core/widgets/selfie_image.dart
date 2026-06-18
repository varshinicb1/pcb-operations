import 'dart:convert';
import 'package:flutter/material.dart';

class SelfieImage extends StatelessWidget {
  final String? base64;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const SelfieImage({
    super.key,
    this.base64,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (base64 == null || base64!.isEmpty) {
      return Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.person, color: Colors.grey, size: 24),
      );
    }

    try {
      final bytes = base64Decode(base64!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(bytes, width: width, height: height, fit: fit),
      );
    } catch (_) {
      return Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
      );
    }
  }
}
