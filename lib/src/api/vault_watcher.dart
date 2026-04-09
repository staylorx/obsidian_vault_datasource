import 'dart:async';
import 'package:watcher/watcher.dart';
import 'package:fpdart/fpdart.dart';
import '../domain/failures.dart';
import 'obsidian_api.dart';

/// Types of file changes detected by the vault watcher.
enum VaultChangeType {
  created,
  modified,
  deleted,
}

/// Represents a change to a file in the vault.
class VaultChange {
  const VaultChange(this.type, this.path);

  final VaultChangeType type;
  final String path;

  @override
  String toString() => 'VaultChange($type, $path)';
}

/// Watches a vault for file system changes using streams.
class VaultWatcher {
  VaultWatcher(this._obsidianVault);

  final ObsidianVault _obsidianVault;
  StreamSubscription<WatchEvent>? _subscription;
  final _changeController = StreamController<VaultChange>.broadcast();

  Stream<VaultChange> get changes => _changeController.stream;

  TaskEither<Failure, Unit> start() {
    return TaskEither(() async {
      if (_subscription != null) {
        return const Right(unit);
      }

      try {
        final watcher = DirectoryWatcher(_obsidianVault.path);
        _subscription = watcher.events.listen((event) {
          if (event.path.endsWith('.md')) {
            final changeType = event.type == ChangeType.REMOVE
                ? VaultChangeType.deleted
                : event.type == ChangeType.ADD
                    ? VaultChangeType.created
                    : VaultChangeType.modified;
            _changeController.add(VaultChange(changeType, event.path));
          }
        });

        return const Right(unit);
      } catch (e) {
        return Left(WatchFailure('$e'));
      }
    });
  }

  TaskEither<Failure, Unit> stop() {
    return TaskEither(() async {
      await _subscription?.cancel();
      _subscription = null;
      return const Right(unit);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _changeController.close();
  }
}

extension ObsidianVaultWatch on ObsidianVault {
  VaultWatcher watch() {
    return VaultWatcher(this);
  }
}
