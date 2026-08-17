import 'package:flutter/material.dart';

class DrawerMenuTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final GestureTapCallback? onTap;
  final Widget? trailing;
  const DrawerMenuTile({
    super.key,
    required this.title,
    required this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: ListTile(
        title: Text(title),
        onTap: onTap,
        leading: leading,
        textColor: Theme.of(context).colorScheme.primary,
        trailing: trailing,
        contentPadding: EdgeInsets.only(left: 16, right: 0),
      ),
    );
  }
}
