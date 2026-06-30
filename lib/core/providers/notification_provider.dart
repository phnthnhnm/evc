import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current toast message, or null when no toast is shown.
final toastMessageProvider = NotifierProvider<ToastMessageNotifier, String?>(
  ToastMessageNotifier.new,
);

class ToastMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;
  void dismiss() => state = null;
}

/// Show a toast notification. Safe to call from build methods — provider
/// modification is deferred to after the current frame via
/// [WidgetsBinding.addPostFrameCallback].
final class ToastNotification {
  static void show(WidgetRef ref, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toastMessageProvider.notifier).show(message);
    });
  }
}

/// Place at the root of the app to render toast notifications.
///
/// Typical usage (in [MaterialApp.router.builder]):
/// ```dart
/// builder: (context, child) => ToastLayer(child: child!),
/// ```
class ToastLayer extends ConsumerWidget {
  final Widget child;
  const ToastLayer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(toastMessageProvider);
    return Stack(
      children: [
        child,
        if (message != null)
          Positioned(
            top: 40,
            right: 24,
            child: _ToastWidget(
              message: message,
              onClose: () => ref.read(toastMessageProvider.notifier).dismiss(),
            ),
          ),
      ],
    );
  }
}

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

class _ToastWidgetState extends State<_ToastWidget> {
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _autoDismiss = Timer(const Duration(seconds: 5), widget.onClose);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}
