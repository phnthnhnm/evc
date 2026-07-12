import 'package:riverpod/riverpod.dart';

class NavigationHistoryState {
  final List<String> history;
  final int currentIndex;

  const NavigationHistoryState({
    this.history = const [],
    this.currentIndex = -1,
  });

  bool get canGoBack => currentIndex > 0;
  bool get canGoForward =>
      currentIndex >= 0 && currentIndex < history.length - 1;

  NavigationHistoryState copyWith({List<String>? history, int? currentIndex}) {
    return NavigationHistoryState(
      history: history ?? this.history,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class NavigationHistoryNotifier extends Notifier<NavigationHistoryState> {
  bool _internalNavigation = false;

  @override
  NavigationHistoryState build() => const NavigationHistoryState();

  void recordRoute(String path) {
    if (_internalNavigation) return;

    if (state.currentIndex >= 0 &&
        state.currentIndex < state.history.length &&
        state.history[state.currentIndex] == path) {
      return;
    }

    final newHistory = List<String>.from(
      state.currentIndex >= 0 && state.currentIndex < state.history.length - 1
          ? state.history.sublist(0, state.currentIndex + 1)
          : state.history,
    );

    newHistory.add(path);
    state = state.copyWith(
      history: newHistory,
      currentIndex: newHistory.length - 1,
    );
  }

  String? prepareBack() {
    if (!state.canGoBack) return null;
    _internalNavigation = true;
    final newIndex = state.currentIndex - 1;
    state = state.copyWith(currentIndex: newIndex);
    return state.history[newIndex];
  }

  String? prepareForward() {
    if (!state.canGoForward) return null;
    _internalNavigation = true;
    final newIndex = state.currentIndex + 1;
    state = state.copyWith(currentIndex: newIndex);
    return state.history[newIndex];
  }

  void onNavigationComplete() {
    _internalNavigation = false;
  }
}

final navigationHistoryProvider =
    NotifierProvider<NavigationHistoryNotifier, NavigationHistoryState>(
      NavigationHistoryNotifier.new,
    );
