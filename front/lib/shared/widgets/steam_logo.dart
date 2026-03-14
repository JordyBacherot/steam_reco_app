import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SteamLogo extends StatelessWidget {
  final double size;
  final Color color;

  const SteamLogo({
    super.key,
    this.size = 40,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/steam_icon.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}