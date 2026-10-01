import 'package:flutter/material.dart';
import 'package:janus/theme/theme.dart';

/// A reusable Material-based text field styled to match the app's glass settings
/// panels while avoiding the dependency on the liquid glass widget API.
class MaterialTextField extends StatelessWidget {
  const MaterialTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.decoration,
    this.contentPadding,
    this.borderRadius,
    // Kept for compatibility with the previous GlassTextField call sites.
    this.shape,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadiusGeometry? borderRadius;
  final Object? shape;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = (borderRadius ?? BorderRadius.circular(AppRadius.lg))
        .resolve(Directionality.of(context));
    final padding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.contentInterval,
          vertical: AppSpacing.contentInterval,
        );

    final effectiveDecoration = (decoration ?? const InputDecoration()).copyWith(
      hintText: hintText ?? decoration?.hintText,
      contentPadding: padding,
      filled: decoration?.filled ?? true,
      fillColor: decoration?.fillColor ?? theme.colorScheme.surfaceContainerHigh,
      prefixIcon: prefixIcon ?? decoration?.prefixIcon,
      suffixIcon: suffixIcon ?? decoration?.suffixIcon,
      border: decoration?.border ??
          OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: radius,
          ),
      enabledBorder: decoration?.enabledBorder ??
          OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: radius,
          ),
      focusedBorder: decoration?.focusedBorder ??
          OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 3,
            ),
            borderRadius: radius,
          ),
      disabledBorder: decoration?.disabledBorder ??
          OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: radius,
          ),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      decoration: effectiveDecoration,
    );
  }
}
