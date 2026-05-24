import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodel/auth_session.dart';
import '../theme/design_tokens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'menu_items.dart';

class SideMenu extends ConsumerStatefulWidget {
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<AppMenuItem> items;

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  /// Tracks which parent keyNames are currently expanded.
  final Set<String> _expandedParents = {};

  final logo = "assets/images/logo.png";

  @override
  Widget build(BuildContext context) {
    // Build a flat list of navigable items, mapping each to a flat index.
    // Parents with children are NOT navigable themselves.
    final flatItems = _buildFlatItems(widget.items);

    return Container(
      width: 260.w,
      padding: EdgeInsets.only(right: 16.w),
      decoration: const BoxDecoration(color: DesignTokens.beige),
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo area
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Image.asset(
              logo,
              width: 137.w,
              height: 167.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16.h),
          ..._buildMenuWidgets(widget.items, flatItems),
          const Spacer(),
          IconButton(
            icon: const Icon(FluentIcons.sign_out),
            onPressed: () {
              ref.read(authSessionProvider.notifier).clear();
              // ignore: avoid_print
              print(
                "auth try  ${ref.read(authSessionProvider).refreshToken}",
              );
            },
          ),
          Text(
            'v0.1',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: DesignTokens.brown),
          ),
        ],
      ),
    );
  }

  /// Returns a flat ordered list of navigable keyNames matching
  /// the indices used by [homeNavIndexProvider].
  List<String> _buildFlatItems(List<AppMenuItem> items) {
    final flat = <String>[];
    for (final item in items) {
      if (item.hasChildren) {
        for (final child in item.children) {
          flat.add(child.keyName);
        }
      } else {
        flat.add(item.keyName);
      }
    }
    return flat;
  }

  /// Builds the widget tree for the menu, handling parents with children.
  List<Widget> _buildMenuWidgets(
    List<AppMenuItem> items,
    List<String> flatItems,
  ) {
    final widgets = <Widget>[];
    for (final item in items) {
      if (item.hasChildren) {
        final isExpanded = _expandedParents.contains(item.keyName);

        // Parent header — toggles expand/collapse
        widgets.add(
          _ParentMenuItem(
            title: item.title,
            icon: item.icon,
            isExpanded: isExpanded,
            isChildSelected: item.children.any(
              (child) =>
                  flatItems.indexOf(child.keyName) == widget.selectedIndex,
            ),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedParents.remove(item.keyName);
                } else {
                  _expandedParents.add(item.keyName);
                }
              });
            },
          ),
        );

        // Child items (shown only when expanded)
        if (isExpanded) {
          for (final child in item.children) {
            final flatIndex = flatItems.indexOf(child.keyName);
            widgets.add(
              _ChildMenuItem(
                index: flatIndex,
                selectedIndex: widget.selectedIndex,
                title: child.title,
                icon: child.icon,
                onTap: widget.onChanged,
              ),
            );
          }
        }
      } else {
        // Regular top-level item
        final flatIndex = flatItems.indexOf(item.keyName);
        widgets.add(
          _MenuItem(
            index: flatIndex,
            selectedIndex: widget.selectedIndex,
            title: item.title,
            icon: item.icon,
            onTap: widget.onChanged,
          ),
        );
      }
    }
    return widgets;
  }
}

// ─── Regular menu item ───────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.index,
    required this.selectedIndex,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final String title;
  final IconData icon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Button(
        onPressed: () => onTap(index),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          backgroundColor: WidgetStateProperty.all(
            selected ? DesignTokens.brown : Colors.transparent,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: selected
                  ? BorderSide.none
                  : BorderSide(color: DesignTokens.brown, width: 1),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? DesignTokens.beige : DesignTokens.brown,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              icon,
              color: selected ? DesignTokens.beige : DesignTokens.brown,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Parent menu item (expandable header) ────────────────────────────

class _ParentMenuItem extends StatelessWidget {
  const _ParentMenuItem({
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.isChildSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isExpanded;
  final bool isChildSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Button(
        onPressed: onTap,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          backgroundColor: WidgetStateProperty.all(
            isChildSelected
                ? DesignTokens.brown.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: DesignTokens.brown, width: 1),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: DesignTokens.brown,
                  fontWeight: isChildSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              isExpanded ? FluentIcons.chevron_up : FluentIcons.chevron_down,
              color: DesignTokens.brown,
              size: 12.sp,
            ),
            SizedBox(width: 6.w),
            Icon(icon, color: DesignTokens.brown),
          ],
        ),
      ),
    );
  }
}

// ─── Child menu item (indented sub-item) ─────────────────────────────

class _ChildMenuItem extends StatelessWidget {
  const _ChildMenuItem({
    required this.index,
    required this.selectedIndex,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final String title;
  final IconData icon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 24.w, bottom: 6),
      child: Button(
        onPressed: () => onTap(index),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          backgroundColor: WidgetStateProperty.all(
            selected ? DesignTokens.brown : Colors.transparent,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: selected
                  ? BorderSide.none
                  : BorderSide(
                      color: DesignTokens.brown.withValues(alpha: 0.4),
                      width: 1,
                    ),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? DesignTokens.beige : DesignTokens.brown,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              icon,
              color: selected ? DesignTokens.beige : DesignTokens.brown,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
