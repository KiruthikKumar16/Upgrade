import 'package:flutter/material.dart';

/// App logo icon (UPGRADE). Use [color] to tint for theme (e.g. nav bar).
/// Omit [color] for the default white icon on transparent background (e.g. on blue circle).
class AppLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogoIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color;
    
    return Image.asset(
      'assets/icons/icon_no_bg.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: effectiveColor,
      colorBlendMode: effectiveColor != null ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => Icon(
        Icons.rocket_launch_rounded,
        size: size,
        color: effectiveColor ?? Colors.white,
      ),
    );
  }
}
