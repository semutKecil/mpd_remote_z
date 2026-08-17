import 'package:flutter/material.dart';

class SimpleDialogOptionDefault<T> extends StatelessWidget {
  final String title;
  final T value;
  const SimpleDialogOptionDefault({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, value),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }
}
