import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io' as io;

class UniversalImage extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const UniversalImage({
    Key? key,
    this.imagePath,
    this.imageBytes,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, use Image.memory if bytes are available
      if (imageBytes != null) {
        return Image.memory(
          imageBytes!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      }
      // For web, use Image.network for URLs
      if (imagePath != null && (imagePath!.startsWith('http') || imagePath!.startsWith('https'))) {
        return Image.network(
          imagePath!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.error);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? const Center(child: CircularProgressIndicator());
          },
        );
      }
    } else {
      // For mobile, use Image.file
      if (imagePath != null) {
        return Image.file(
          io.File(imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      }
    }

    // Fallback
    return errorWidget ?? placeholder ?? const Icon(Icons.image);
  }
}
