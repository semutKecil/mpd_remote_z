import 'package:flutter/material.dart';

class PlayerControllerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  const PlayerControllerButton({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      icon: Icon(icon, size: 50),
    );
  }
}
