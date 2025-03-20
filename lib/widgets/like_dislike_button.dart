import 'package:flutter/material.dart';

class LikeDislikeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const LikeDislikeButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 48,
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: onPressed,
    );
  }
}
