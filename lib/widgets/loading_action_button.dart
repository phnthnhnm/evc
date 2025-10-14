import 'package:flutter/material.dart';

class LoadingActionButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String text;
  final Widget? loadingIcon;
  final double height;

  const LoadingActionButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.icon,
    required this.text,
    this.loadingIcon,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? (loadingIcon ??
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(text),
                ],
              ),
      ),
    );
  }
}
