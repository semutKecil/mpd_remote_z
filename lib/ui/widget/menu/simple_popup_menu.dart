import 'package:flutter/material.dart';

class SimplePopupMenu extends StatelessWidget {
  final Widget icon;
  final Map<String, VoidCallback> items;
  final ButtonStyle? style;
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;
  const SimplePopupMenu({
    super.key,
    required this.icon,
    required this.items,
    this.popupMenuKey,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      key: popupMenuKey,
      color: Theme.of(context).colorScheme.primaryContainer,
      icon: icon,
      elevation: 10,
      // offset: const Offset(-50, 0),
      style: style,
      itemBuilder: (context) {
        List<PopupMenuItem<int>> d = [];
        for (var i = 0; i < items.length; i++) {
          d.add(
            PopupMenuItem<int>(
              value: i,
              child: Text(
                items.keys.toList()[i],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          );
        }
        return d;
      },
      onSelected: (value) async {
        items.entries.toList()[value].value.call();
      },
    );
  }
}
