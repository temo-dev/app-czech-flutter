import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VocabImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const VocabImage({super.key, required this.imageUrl, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: imageUrl.startsWith('assets/')
            ? Image.asset(imageUrl, fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white.withOpacity(0.15),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.white.withOpacity(0.15),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 36),
                  ),
                ),
              ),
      ),
    );
  }
}
