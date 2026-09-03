import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/common/widgets/containers/circular_container.dart';
import 'package:chat_app/common/widgets/shimmer/shimmer_effect.dart';
import 'package:chat_app/utils/constants/colors.dart';
import 'package:chat_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class UPAvatar extends StatelessWidget {
  const UPAvatar({
    super.key,
    required this.userName,
    this.imageUrl,
    this.memoryBytes,
    this.onTap,
    this.radius = 26,
    this.showOnlineDot = false,
  });

  final String userName;
  final String? imageUrl;
  final Uint8List? memoryBytes;
  final VoidCallback? onTap;

  /// Avatar circle radius — default 26 (52px diameter)
  final double radius;

  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    bool isDark = UPHelperFunctions.isDarkMode(context);

    // resolve background image (memory takes priority over network)
    Widget? backgroundImage;
    if (memoryBytes != null) {
      backgroundImage = Image.memory(memoryBytes!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      backgroundImage = CachedNetworkImage(
          imageUrl: imageUrl!,
        fit: BoxFit.cover,
        height: radius * 2,
        width: radius * 2,
        placeholder: (context, url) => const UPShimmerEffect(),
      );
    }

    final avatar = Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10000),
        child: UPCircularContainer(
          width: radius * 2,
          height: radius * 2,
          backgroundColor: isDark ? UPColors.primaryDark : UPColors.primary,
          child: backgroundImage ?? Center(
            child: Text(
              _initials(userName),
              style: TextStyle(fontSize: radius * 0.6, fontWeight: FontWeight.w600, color: UPColors.lightGrey),
            ),
          ),
        ),
      ),
    );


    // Online dot overlay
    final dotSize = radius * 0.42;
    final borderSize = dotSize * 0.35;

    final onlineDot = Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dotSize + (isDark ? borderSize * 2 : borderSize),
            height: dotSize + (isDark ? borderSize * 2 : borderSize),
            decoration: BoxDecoration(
              color: isDark ? UPColors.primaryDark : UPColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: UPColors.onlineGreen, // Material green — universal online color
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (!showOnlineDot && onTap == null) return avatar;

    if (showOnlineDot && onTap == null) return onlineDot;

    if (showOnlineDot && onTap != null) return GestureDetector(onTap: onTap, child: onlineDot);

    return GestureDetector(onTap: onTap, child: avatar);
  }

  /// Returns up to 2 initials — "Abdul Haseeb" → "AH", "Jane" → "J"
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
