import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';

class CommandPaletteState {
  final bool isOpen;
  final String searchQuery;
  final List<String> recentResonatorIds;
  final int highlightedIndex;

  const CommandPaletteState({
    this.isOpen = false,
    this.searchQuery = '',
    this.recentResonatorIds = const [],
    this.highlightedIndex = 0,
  });

  CommandPaletteState copyWith({
    bool? isOpen,
    String? searchQuery,
    List<String>? recentResonatorIds,
    int? highlightedIndex,
  }) {
    return CommandPaletteState(
      isOpen: isOpen ?? this.isOpen,
      searchQuery: searchQuery ?? this.searchQuery,
      recentResonatorIds: recentResonatorIds ?? this.recentResonatorIds,
      highlightedIndex: highlightedIndex ?? this.highlightedIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandPaletteState &&
          runtimeType == other.runtimeType &&
          isOpen == other.isOpen &&
          searchQuery == other.searchQuery &&
          highlightedIndex == other.highlightedIndex &&
          _listEquals(recentResonatorIds, other.recentResonatorIds);

  @override
  int get hashCode => Object.hash(
    isOpen,
    searchQuery,
    highlightedIndex,
    Object.hashAll(recentResonatorIds),
  );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final commandPaletteProvider =
    NotifierProvider<CommandPaletteNotifier, CommandPaletteState>(
      CommandPaletteNotifier.new,
    );

class CommandPaletteNotifier extends Notifier<CommandPaletteState> {
  static const _maxRecent = 20;

  @override
  CommandPaletteState build() {
    final storage = ref.watch(storageServiceProvider);
    final ids = storage.loadRecentResonatorIdsSync();
    return CommandPaletteState(recentResonatorIds: ids);
  }

  bool get isOpen => state.isOpen;

  void open() {
    state = state.copyWith(isOpen: true, searchQuery: '', highlightedIndex: 0);
  }

  void close() {
    state = state.copyWith(isOpen: false);
  }

  void toggle() {
    if (state.isOpen) {
      close();
    } else {
      open();
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query, highlightedIndex: 0);
  }

  void moveHighlight(int delta, int resultCount) {
    if (resultCount <= 0) {
      state = state.copyWith(highlightedIndex: 0);
      return;
    }
    var newIndex = (state.highlightedIndex + delta) % resultCount;
    if (newIndex < 0) {
      newIndex += resultCount;
    }
    state = state.copyWith(highlightedIndex: newIndex);
  }

  void selectResonator(String resonatorId) {
    _addToRecent(resonatorId);
    state = state.copyWith(isOpen: false);
  }

  void recordNavigation(String resonatorId) {
    _addToRecent(resonatorId);
  }

  void _addToRecent(String resonatorId) {
    final ids = List<String>.from(state.recentResonatorIds);
    ids.remove(resonatorId);
    ids.insert(0, resonatorId);
    if (ids.length > _maxRecent) {
      ids.removeRange(_maxRecent, ids.length);
    }
    state = state.copyWith(recentResonatorIds: ids);

    ref.read(storageServiceProvider).saveRecentResonatorIds(ids);
  }
}
