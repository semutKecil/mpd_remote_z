import 'package:flutter/material.dart';

class DrawerExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget leading;
  const DrawerExpansionTile({
    super.key,
    required this.title,
    required this.leading,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: ExpansionTile(
        leading: leading,
        title: Text(title),
        collapsedTextColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Theme.of(context).colorScheme.primary,
        iconColor: Theme.of(context).colorScheme.primary,
        children: children.map((e) {
          return Padding(padding: const EdgeInsets.only(left: 20), child: e);
        }).toList(),
      ),
    );
  }
}
