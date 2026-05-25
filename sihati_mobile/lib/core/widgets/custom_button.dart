import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final String? svgIcon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.icon,
    this.svgIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primary;
    final buttonTextColor = textColor ?? AppColors.white;

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: buttonColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(buttonColor),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 2,
        ),
        child: _buildContent(buttonTextColor),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? backgroundColor ?? AppColors.primary : AppColors.white,
          ),
        ),
      );
    }

    if (icon != null || svgIcon != null) {
      final iconColor = isOutlined ? (backgroundColor ?? AppColors.primary) : color;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgIcon != null)
            SvgPicture.asset(svgIcon!, width: 20, height: 20, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))
          else if (icon != null)
            Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: isOutlined ? (backgroundColor ?? AppColors.primary) : color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
