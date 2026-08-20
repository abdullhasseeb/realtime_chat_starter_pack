import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageView extends StatelessWidget {
  const FullscreenImageView({super.key, required this.imageUrl, required this.headers, required this.isLocalImage});

  final String imageUrl;
  final Map<String, String> headers;
  final bool isLocalImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Image Preview
          PhotoView(
            imageProvider: isLocalImage
                ? FileImage(File(imageUrl))
                : CachedNetworkImageProvider(imageUrl, headers: headers),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          /// Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
