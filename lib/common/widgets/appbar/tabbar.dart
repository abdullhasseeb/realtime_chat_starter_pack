
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class UPTabBar extends StatefulWidget implements PreferredSizeWidget{
  const UPTabBar({super.key, required this.tabController, required this.tabs});

  final TabController tabController;
  final List<String> tabs; // just pass strings, not widgets


  @override
  State<UPTabBar> createState() => _UPTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UPTabBarState extends State<UPTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!widget.tabController.indexIsChanging) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TabBar(
      controller: widget.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      indicatorColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tabs: List.generate(widget.tabs.length, (index) {
        final selected = widget.tabController.index == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? (isDark ? Colors.white : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(1000),

          ),
          child: Text(
            widget.tabs[index],
            style: TextStyle(
              color: selected
                  ? UPColors.primary
                  : Colors.white.withValues(alpha: 0.7),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        );
      }),
    );
  }
}
