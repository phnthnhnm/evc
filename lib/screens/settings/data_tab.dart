// import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/storage_service.dart';
import '../../utils/confirm_dialog.dart';
import '../../utils/toast_utils.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  Future<void> _backupData() async {
    final file = await StorageService.getJsonFile();
    if (!await file.exists()) {
      if (!mounted) return;
      showTopRightToast(context, 'No echo_sets.json found');
      return;
    }
    final jsonString = await file.readAsString();
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select folder to save backup',
    );
    if (selectedDirectory != null) {
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
      await backupFile.writeAsString(jsonString);
      if (!mounted) return;
      showTopRightToast(context, 'Backup saved as $filename');
    }
  }

  Future<void> _restoreData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select backup JSON file',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final inputJson = await file.readAsString();
      try {
        final echoFile = await StorageService.getJsonFile();
        await echoFile.writeAsString(inputJson);
        if (!mounted) return;
        showTopRightToast(context, 'Data restored!');
      } catch (e) {
        if (!mounted) return;
        showTopRightToast(context, 'Invalid backup data');
      }
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Confirm Reset',
      content:
          'Are you sure you want to reset all data? This cannot be undone.',
      confirmText: 'Reset',
      confirmColor: Colors.red,
    );
    if (confirmed) {
      final echoFile = await StorageService.getJsonFile();
      await echoFile.writeAsString('{}');
      if (!mounted) return;
      showTopRightToast(context, 'All data has been reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
