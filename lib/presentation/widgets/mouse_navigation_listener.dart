import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/navigation_history_provider.dart';

class MouseNavigationListener extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouter router;

  const MouseNavigationListener({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  ConsumerState<MouseNavigationListener> createState() =>
      _MouseNavigationListenerState();
}

class _MouseNavigationListenerState
    extends ConsumerState<MouseNavigationListener> {
  void _handlePointerDown(PointerDownEvent event) {
    final notifier = ref.read(navigationHistoryProvider.notifier);
    String? targetRoute;

    if (event.buttons == kBackMouseButton) {
      targetRoute = notifier.prepareBack();
    } else if (event.buttons == kForwardMouseButton) {
      targetRoute = notifier.prepareForward();
    }

    if (targetRoute != null) {
      widget.router.go(targetRoute);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifier.onNavigationComplete();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: widget.child,
    );
  }
}
