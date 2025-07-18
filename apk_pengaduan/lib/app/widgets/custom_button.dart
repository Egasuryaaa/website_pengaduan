import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primaryColor;
    final buttonTextColor = textColor ?? AppColors.textWhite;
    final buttonFontSize = fontSize ?? AppSizes.fontSize16;
    final buttonFontWeight = fontWeight ?? FontWeight.w600;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(
      horizontal: AppSizes.spacing24,
      vertical: AppSizes.spacing12,
    );
    final buttonBorderRadius = borderRadius ?? BorderRadius.circular(AppSizes.radius12);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SpinKitCircle(
            color: buttonTextColor,
            size: 20,
          )
        else ...[
          if (icon != null) ...[
            Icon(
              icon,
              color: buttonTextColor,
              size: AppSizes.iconSmall,
            ),
            const SizedBox(width: AppSizes.spacing8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: buttonFontWeight,
              color: buttonTextColor,
            ),
          ),
        ],
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: buttonBorderRadius,
            ),
            side: BorderSide(
              color: buttonColor,
              width: 1.5,
            ),
          ),
          child: buttonChild,
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
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          elevation: AppSizes.cardElevation,
        ),
        child: buttonChild,
      ),
    );
  }
}
