import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/named_game_save_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/illustration.dart';

/// The three conversations the shelf of named saves has with the table:
/// keeping a game under a name (from the board's menu), choosing one to
/// load (from the setup screen), and the warning before a game in
/// progress is replaced by a new or a loaded one.

/// Keeps [state] under a name the player types.
///
/// The name is proposed, never demanded: the riders' names, or the name
/// the game was loaded under so that saving again replaces the shelf's
/// copy instead of piling a second one beside it. Null when the player
/// cancels, or when the shelf is full and the name was new — which is
/// said in a toast, not swallowed.
Future<NamedGameSave?> saveGameWithName(
  BuildContext context,
  WidgetRef ref,
  GameState state,
) async {
  final l10n = AppLocalizations.of(context);
  final shelf = ref.read(gameSaveServiceProvider).named;
  final proposed =
      shelf.byGame(state.gameId)?.name ?? _proposedName(state, shelf, l10n);
  final typed = await showDialog<String>(
    context: context,
    builder: (_) => _SaveNameDialog(
      initial: proposed,
      full: shelf.isFull && shelf.byName(proposed) == null,
      l10n: l10n,
    ),
  );
  if (typed == null) return null;
  final name = NamedGameSaveService.normalize(typed).isEmpty ? proposed : typed;
  final saved = await shelf.save(state, name: name);
  if (saved == null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savesFull(NamedGameSaveService.maxSaves))),
    );
  }
  return saved;
}

/// The riders' names, which is how a family tells its games apart; a
/// number after them when another game already holds that name, so a
/// second evening never overwrites the first without being asked to.
String _proposedName(
  GameState state,
  NamedGameSaveService shelf,
  AppLocalizations l10n,
) {
  final humans = [
    for (final p in state.players)
      if (p.isHuman && p.name.trim().isNotEmpty) p.name.trim(),
  ];
  final base = humans.isEmpty ? l10n.defaultSaveName : humans.join(', ');
  var candidate = base;
  for (var n = 2; shelf.byName(candidate) != null; n++) {
    candidate = '$base $n';
  }
  return candidate;
}

class _SaveNameDialog extends StatefulWidget {
  const _SaveNameDialog({
    required this.initial,
    required this.full,
    required this.l10n,
  });

  final String initial;

  /// The shelf is full and this name would be a new row: said under the
  /// field, so the player knows to reuse a name or cancel and delete.
  final bool full;
  final AppLocalizations l10n;

  @override
  State<_SaveNameDialog> createState() => _SaveNameDialogState();
}

class _SaveNameDialogState extends State<_SaveNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void initState() {
    super.initState();
    // Selected whole, so typing replaces the proposal and a tap keeps it.
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.saveGame),
      content: TextField(
        key: const Key('save-game-name'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.saveGameNameLabel,
          // The cap is generous; counting down to it is noise.
          counterText: '',
          helperText: widget.full
              ? l10n.savesFull(NamedGameSaveService.maxSaves)
              : null,
          helperMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('save-game-confirm'),
          onPressed: _submit,
          child: Text(l10n.saveAction),
        ),
      ],
    );
  }
}

/// Lets the table pick a saved game to play, or delete one. Returns the
/// chosen save; null when the sheet is dismissed.
///
/// An empty shelf is not a dead end: it says where the save command
/// lives, which is how a table learns the feature exists at all.
Future<NamedGameSave?> showLoadGameSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<NamedGameSave>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _LoadGameSheet(),
  );
}

class _LoadGameSheet extends ConsumerStatefulWidget {
  const _LoadGameSheet();

  @override
  ConsumerState<_LoadGameSheet> createState() => _LoadGameSheetState();
}

class _LoadGameSheetState extends ConsumerState<_LoadGameSheet> {
  late List<NamedGameSave> _saves = _shelf.list();

  NamedGameSaveService get _shelf => ref.read(gameSaveServiceProvider).named;

  Future<void> _delete(NamedGameSave save) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSave),
        content: Text(l10n.deleteSaveConfirm(save.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            key: const Key('delete-save-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _shelf.delete(save.id);
    if (mounted) setState(() => _saves = _shelf.list());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.loadGame,
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
            ),
            if (_saves.isEmpty)
              Padding(
                key: const Key('no-saved-games'),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 40,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.noSavedGames,
                      textAlign: TextAlign.center,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    _MenuHint(
                      l10n.noSavedGamesHint,
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: _saves.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _SaveTile(
                    save: _saves[index],
                    onLoad: () => Navigator.of(context).pop(_saves[index]),
                    onDelete: () => _delete(_saves[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One saved game: a postcard of its course, its name, who rides it and
/// how far they are, and when it was kept.
class _SaveTile extends StatelessWidget {
  const _SaveTile({
    required this.save,
    required this.onLoad,
    required this.onDelete,
  });

  final NamedGameSave save;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loc = MaterialLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final mode = switch (save.mode) {
      GameMode.solo => l10n.soloMode,
      GameMode.family => l10n.familyMode,
    };
    final length = switch (save.variant) {
      GameVariant.quick => l10n.raceLengthShort,
      GameVariant.duo => l10n.raceLengthMedium,
      _ => l10n.raceLengthFull,
    };
    // The course by its mood word — the word the setup tile uses, next
    // to the very same picture — rather than its full name, which no
    // phone row has room for beside the race length.
    final course = switch (save.circuitId) {
      CircuitId.oasisRoute => l10n.courseCalm,
      CircuitId.caravanTrail => l10n.courseLively,
      CircuitId.greatRide => l10n.courseIntense,
    };
    final riders = save.riderNames.join(', ');
    // The riders are the proposed name: when the table kept it, the row
    // does not say them twice.
    final showRiders =
        riders.isNotEmpty && riders.toLowerCase() != save.name.toLowerCase();
    return ListTile(
      key: Key('save-${save.id}'),
      onTap: onLoad,
      isThreeLine: showRiders,
      leading: ArtPanel(
        asset: AppArt.forCircuit(save.circuitId),
        width: 56,
        height: 46,
        radius: 10,
      ),
      title: Text(
        save.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRiders)
            Text(
              riders,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          Text(
            '$mode · $length · $course',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(save.progress * 100).round()}%',
                style: text.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                loc.formatShortMonthDay(save.savedAt),
                style: text.labelSmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          IconButton(
            key: Key('delete-save-${save.id}'),
            tooltip: l10n.deleteSave,
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// A line of help that names the board's menu button by showing it: the
/// "≡" in the string is drawn as the icon itself, so no font decides
/// whether it appears.
class _MenuHint extends StatelessWidget {
  const _MenuHint(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final at = text.indexOf('≡');
    if (at < 0) return Text(text, textAlign: TextAlign.center, style: style);
    final size = (style?.fontSize ?? 12) * 1.25;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, at)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.menu, size: size, color: style?.color),
          ),
          TextSpan(text: text.substring(at + 1)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Before a new or a loaded game takes the place of the one in progress.
///
/// Silent replacement was the finding of the navigation audit: home →
/// Solo → riders → Start threw away an evening's race without a word.
/// Nothing is asked when there is nothing to lose — no game in progress,
/// or one the shelf already holds as it stands. Otherwise the table
/// chooses: keep it under a name first, replace it, or think again.
/// True when the caller may go on.
Future<bool> confirmReplaceGameInProgress(
  BuildContext context,
  WidgetRef ref,
) async {
  final saveService = ref.read(gameSaveServiceProvider);
  final current = saveService.load();
  if (current == null || current.turnPhase == TurnPhase.gameOver) return true;
  if (saveService.named.holds(current)) return true;

  final l10n = AppLocalizations.of(context);
  final choice = await showDialog<_ReplaceChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.gameInProgressTitle),
      content: Text(l10n.gameInProgressReplaceBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
        ),
        TextButton(
          key: const Key('replace-game'),
          onPressed: () => Navigator.of(dialogContext).pop(_ReplaceChoice.replace),
          child: ButtonLabel(l10n.replaceWithoutSaving),
        ),
        FilledButton(
          key: const Key('keep-game'),
          onPressed: () => Navigator.of(dialogContext).pop(_ReplaceChoice.keep),
          child: ButtonLabel(l10n.keepUnderName),
        ),
      ],
    ),
  );
  switch (choice) {
    case null:
      return false;
    case _ReplaceChoice.replace:
      return true;
    case _ReplaceChoice.keep:
      if (!context.mounted) return false;
      final saved = await saveGameWithName(context, ref, current);
      if (saved != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gameSavedAs(saved.name))),
        );
      }
      return saved != null;
  }
}

enum _ReplaceChoice { replace, keep }
