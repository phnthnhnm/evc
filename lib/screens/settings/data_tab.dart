import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/storage_service.dart';
import '../../utils/confirm_dialog.dart';
import '../../utils/echo_set_provider.dart';
import '../../utils/theme_provider.dart';
import '../../utils/toast_utils.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  EchoSetProvider _getEchoSetProvider() =>
      Provider.of<EchoSetProvider>(context, listen: false);
  ThemeProvider _getThemeProvider() =>
      Provider.of<ThemeProvider>(context, listen: false);
  Future<void> _backupData() async {
    final backupJson = await StorageService.backupAllData();
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
      await backupFile.writeAsString(backupJson);
      if (!mounted) return;
      showTopRightToast(context, 'Backup saved as $filename');
    }
  }

  Future<void> _restoreData() async {
    final echoSetProvider = _getEchoSetProvider();
    final themeProvider = _getThemeProvider();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select backup JSON file',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final inputJson = await file.readAsString();
      try {
        await StorageService.restoreAllData(inputJson);
        if (!mounted) return;
        await echoSetProvider.loadAll();
        await themeProvider.loadThemeMode();
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
          'Are you sure you want to reset all data and settings? This cannot be undone.',
      confirmText: 'Reset',
      confirmColor: Colors.red,
    );
    if (confirmed) {
      await StorageService.resetAllData();
      if (!mounted) return;
      showTopRightToast(context, 'All data and settings have been reset');
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
