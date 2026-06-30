import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:evc/core/providers/notification_provider.dart';
import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/core/result.dart';
import 'package:evc/features/settings/providers/settings_provider.dart';
import 'package:evc/presentation/widgets/confirm_dialog.dart';

class DataTab extends ConsumerStatefulWidget {
  const DataTab({super.key});

  @override
  ConsumerState<DataTab> createState() => _DataTabState();
}

class _DataTabState extends ConsumerState<DataTab> {
  Future<void> _backupData() async {
    final storage = ref.read(storageServiceInterfaceProvider);
    final result = await storage.backupAllData();
    switch (result) {
      case Ok(value: final backupJson):
        final selectedDirectory = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select folder to save backup',
        );
        if (selectedDirectory != null && mounted) {
          final now = DateTime.now();
          final formatted =
              '${now.year.toString().padLeft(4, '0')}'
              '${now.month.toString().padLeft(2, '0')}'
              '${now.day.toString().padLeft(2, '0')}'
              '${now.hour.toString().padLeft(2, '0')}'
              '${now.minute.toString().padLeft(2, '0')}'
              '${now.second.toString().padLeft(2, '0')}';
          final filename = 'evc_backup_$formatted.json';
          final backupFile = File('$selectedDirectory/$filename');
          await backupFile.writeAsString(backupJson);
          if (!mounted) return;
          ToastNotification.show(ref, 'Backup saved as $filename');
        }
      case Err():
        if (mounted) ToastNotification.show(ref, 'Failed to create backup');
    }
  }

  Future<void> _restoreData() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Select backup JSON file',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final inputJson = await file.readAsString();
      final storage = ref.read(storageServiceInterfaceProvider);
      final restoreResult = await storage.restoreAllData(inputJson);
      switch (restoreResult) {
        case Ok():
          if (mounted) ToastNotification.show(ref, 'Data restored!');
        case Err():
          if (mounted) ToastNotification.show(ref, 'Invalid backup data');
      }
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Confirm Reset',
      content:
          'Are you sure you want to reset all data and settings? This cannot be undone.',
      confirmText: 'Reset',
      confirmColor: Colors.red,
    );
    if (confirmed) {
      final storage = ref.read(storageServiceInterfaceProvider);
      await storage.resetAllData();
      if (mounted) {
        ToastNotification.show(ref, 'All data and settings have been reset');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showScore = ref.watch(showScoreOnCardProvider);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: showScore,
              onChanged: (v) {
                ref.read(showScoreOnCardProvider.notifier).toggle(v);
              },
              title: const Text('Show overall score on resonator cards'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _backupData,
              icon: const Icon(Icons.save),
              label: const Text('Backup Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _restoreData,
              icon: const Icon(Icons.restore),
              label: const Text('Restore Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withAlpha((0.1 * 255).toInt()),
                foregroundColor: Colors.red,
              ),
              onPressed: _resetData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Reset All Data'),
            ),
          ],
        ),
      ),
    );
  }
}
