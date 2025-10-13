// import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/storage_service.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
          'Are you sure you want to reset all data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final echoFile = await StorageService.getJsonFile();
      await echoFile.writeAsString('{}');
      if (!mounted) return;
      showTopRightToast(context, 'All data has been reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _backupData,
            child: const Text('Backup Data'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _restoreData,
            child: const Text('Restore Data'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _resetData,
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );
  }
}
