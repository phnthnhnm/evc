import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

/// A simple toast notification that appears in the top-right corner.
///
/// Use [ToastNotification.show] to display a message. If a toast is already
/// visible it is replaced immediately.
final class ToastNotification {
  static OverlayEntry? _entry;

  /// Show a toast. Safe to call during build — insertion is deferred.
  static void show(BuildContext context, String message) {
    // Remove any existing toast
    _entry?.remove();
    _entry?.dispose();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 40,
        right: 24,
        child: _ToastWidget(
          message: message,
          onClose: () {
            entry.remove();
            entry.dispose();
            if (_entry == entry) _entry = null;
          },
        ),
      ),
    );

    _entry = entry;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Overlay.of(context).insert(entry);
      } catch (_) {}
    });
  }
}

/// Provider kept for discoverability; the static API is the primary interface.
final notificationProvider = Provider<ToastNotification?>((ref) => null);

// ---------------------------------------------------------------------------
// Internal toast widget
// ---------------------------------------------------------------------------

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const _ToastWidget({required this.message, required this.onClose});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _autoDismiss = Timer(const Duration(seconds: 5), widget.onClose);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
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
                widget.message,
                style:
                    const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
