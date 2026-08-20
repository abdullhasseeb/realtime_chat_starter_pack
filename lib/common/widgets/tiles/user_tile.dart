import 'package:flutter/material.dart';

/// Generic user row used in:
///   - ConversationTile  (home screen chat list)
///   - UserTile          (users screen — start new chat)
///
/// Pass [subtitle] for the last message preview or "Tap to chat".
/// Pass [trailing] for timestamps, unread badges, loading indicators, etc.
/// Pass [onTap] to handle navigation.
class UPUserTile extends StatelessWidget {
  const UPUserTile({
    super.key,
    required this.name,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.avatarRadius = 26,
    required this.leading,
  });

  final String name;
  final Widget? subtitle;

  /// Optional right-side widget — timestamp, badge, spinner, etc.
  final Widget? trailing;

  final VoidCallback? onTap;
  final double avatarRadius;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          tileColor: Colors.transparent,


          contentPadding: EdgeInsets.zero,

          /// ----------------[Avatar]----------------
          minLeadingWidth: avatarRadius * 2,
          leading: SizedBox(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            child: leading,
          ),

          /// ----------------[Name]----------------
          title: Text(
            name,
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          /// ----------------[Subtitle]----------------
          subtitle: subtitle,

          /// ----------------[Trailing]----------------
          trailing: trailing,

          onTap: onTap,
        ),
      ),
    );
  }
}
