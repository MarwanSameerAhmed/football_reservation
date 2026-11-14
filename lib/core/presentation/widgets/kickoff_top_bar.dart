import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';
import 'kickoff_circle_button.dart';

/// Top App Bar matching the header styles in the reference design.
class KickoffTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const KickoffTopBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null &&
        showBackButton &&
        Navigator.of(context).canPop()) {
      leadingWidget = KickoffCircleButton(
        icon: Icons.chevron_left_rounded,
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        size: 40,
        tooltip: 'رجوع',
      );
    }

    return SafeArea(
      bottom: false,
      child: Container(
        height: 60.0,
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        child: Row(
          children: [
            if (leadingWidget != null)
              leadingWidget
            else
              const SizedBox(width: 40),
            Expanded(
              child: Center(
                child: title != null
                    ? Text(
                        title!,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
