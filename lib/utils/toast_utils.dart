import 'package:flutter/material.dart';

void showTopRightToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: 40,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
                onPressed: () {
                  entry.remove();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 5), () {
    if (entry.mounted) entry.remove();
  });
}
