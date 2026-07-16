import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router.dart';
import '../../../domain/models/resonator.dart';
import '../../../presentation/theme/app_colors.dart';
import '../providers/command_palette_provider.dart';
import '../providers/command_palette_results_provider.dart';

/// A widget that sits in the tree and renders the command palette overlay
/// on top of its child when [CommandPaletteState.isOpen] is true.
class CommandPaletteLayer extends ConsumerWidget {
  final Widget child;
  const CommandPaletteLayer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(commandPaletteProvider.select((s) => s.isOpen));

    return Stack(
      children: [
        child,
        if (isOpen) ...[
          GestureDetector(
            onTap: () => ref.read(commandPaletteProvider.notifier).close(),
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
          const _CommandPaletteDialog(),
        ],
      ],
    );
  }
}

class _CommandPaletteDialog extends ConsumerStatefulWidget {
  const _CommandPaletteDialog();

  @override
  ConsumerState<_CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends ConsumerState<_CommandPaletteDialog> {
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // Accept both initial press and key-repeat events so holding a key
    // (especially arrow keys) doesn't leak through to the underlying screen.
    final isDownOrRepeat = event is KeyDownEvent || event is KeyRepeatEvent;
    if (!isDownOrRepeat) return KeyEventResult.ignored;

    final notifier = ref.read(commandPaletteProvider.notifier);
    final state = ref.read(commandPaletteProvider);

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      notifier.close();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _selectHighlighted();
      return KeyEventResult.handled;
    }

    final results = _currentResults();

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      notifier.moveHighlight(1, results.length);
      _scrollToHighlighted();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      notifier.moveHighlight(-1, results.length);
      _scrollToHighlighted();
      return KeyEventResult.handled;
    }

    // Backspace and printable characters: only act on the initial
    // KeyDownEvent, not on repeats, to avoid rapid text changes.
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (state.searchQuery.isNotEmpty) {
          notifier.setSearch(
            state.searchQuery.substring(0, state.searchQuery.length - 1),
          );
        }
        return KeyEventResult.handled;
      }

      if (event.character != null && event.character!.isNotEmpty) {
        final char = event.character!;
        if (char.codeUnitAt(0) >= 0x20) {
          notifier.setSearch(state.searchQuery + char);
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  List<Resonator> _currentResults() {
    final state = ref.read(commandPaletteProvider);
    if (state.searchQuery.trim().isEmpty) {
      final recent = ref.read(commandPaletteRecentResonatorsProvider);
      final all = ref.read(commandPaletteSearchResultsProvider);
      final recentIds = recent.map((r) => r.id).toSet();
      final remaining = all.where((r) => !recentIds.contains(r.id)).toList();
      return [...recent, ...remaining];
    }
    return ref.read(commandPaletteSearchResultsProvider);
  }

  void _selectHighlighted() {
    final state = ref.read(commandPaletteProvider);
    final results = _currentResults();
    if (results.isEmpty) return;

    final index = state.highlightedIndex.clamp(0, results.length - 1);
    final selected = results[index];

    ref.read(commandPaletteProvider.notifier).selectResonator(selected.id);
    router.go('/resonator/${selected.id}');
  }

  void _scrollToHighlighted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const itemHeight = 56.0;
      final state = ref.read(commandPaletteProvider);
      final targetOffset = state.highlightedIndex * itemHeight;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final clamped = targetOffset.clamp(0.0, maxScroll);
      _scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandPaletteProvider);
    final searchResults = ref.watch(commandPaletteSearchResultsProvider);
    final recentResonators = ref.watch(commandPaletteRecentResonatorsProvider);

    final showRecent =
        state.searchQuery.trim().isEmpty && recentResonators.isNotEmpty;

    final recentIds = recentResonators.map((r) => r.id).toSet();
    final remaining = showRecent
        ? searchResults.where((r) => !recentIds.contains(r.id)).toList()
        : searchResults;

    final allResults = showRecent
        ? [...recentResonators, ...remaining]
        : searchResults;

    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Dialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchField(colorScheme, state.searchQuery),
              const Divider(height: 1),
              Flexible(
                child: allResults.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : _buildResultsList(allResults, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme, String query) {
    final hasQuery = query.isNotEmpty;
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 22),
              const SizedBox(width: 12),
              if (hasQuery)
                Expanded(
                  child: _SearchText(
                    query: query,
                    hasFocus: _focusNode.hasFocus,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                    cursorColor: colorScheme.primary,
                  ),
                )
              else
                Expanded(
                  child: Text(
                    'Search resonators...',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        'No resonators found',
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  Widget _buildResultsList(List<Resonator> results, ColorScheme colorScheme) {
    final highlightedIndex = ref.watch(
      commandPaletteProvider.select((s) => s.highlightedIndex),
    );

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        final isHighlighted = index == highlightedIndex;
        return _ResultTile(
          resonator: r,
          isHighlighted: isHighlighted,
          colorScheme: colorScheme,
          onTap: () {
            ref.read(commandPaletteProvider.notifier).selectResonator(r.id);
            router.go('/resonator/${r.id}');
          },
          onHover: () {
            final current = ref.read(commandPaletteProvider).highlightedIndex;
            ref
                .read(commandPaletteProvider.notifier)
                .moveHighlight(index - current, results.length);
          },
        );
      },
    );
  }
}

/// Displays the search query text with an inline blinking cursor right
/// after the last character, mimicking a real text field cursor.
class _SearchText extends StatefulWidget {
  final String query;
  final bool hasFocus;
  final TextStyle style;
  final Color cursorColor;

  const _SearchText({
    required this.query,
    required this.hasFocus,
    required this.style,
    required this.cursorColor,
  });

  @override
  State<_SearchText> createState() => _SearchTextState();
}

class _SearchTextState extends State<_SearchText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.query,
            style: widget.style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.hasFocus)
          FadeTransition(
            opacity: _controller,
            child: Container(
              width: 2,
              height: widget.style.fontSize ?? 20,
              margin: const EdgeInsets.only(left: 1),
              color: widget.cursorColor,
            ),
          ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Resonator resonator;
  final bool isHighlighted;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _ResultTile({
    required this.resonator,
    required this.isHighlighted,
    required this.colorScheme,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighlighted
        ? colorScheme.primaryContainer.withValues(alpha: 0.5)
        : Colors.transparent;

    final echoSet = resonator.savedEchoSet;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(resonator.iconAsset),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  resonator.name,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (echoSet != null) ...[
                Text(
                  echoSet.overallTier,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.tierColor(echoSet.overallTier),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  echoSet.overallScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
