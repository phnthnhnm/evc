import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/toast_utils.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  Future<void> _backupData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    for (var key in keys) {
      data[key] = prefs.get(key);
    }
    final jsonString = jsonEncode(data);
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
      final file = File('$selectedDirectory/$filename');
      await file.writeAsString(jsonString);
      if (mounted) {
        showTopRightToast(context, 'Backup saved as $filename');
      }
    }
  }

  Future<void> _restoreData() async {
    final prefs = await SharedPreferences.getInstance();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select backup JSON file',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final inputJson = await file.readAsString();
      try {
        final Map<String, dynamic> data = jsonDecode(inputJson);
        for (var entry in data.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is String) {
            await prefs.setString(key, value);
          } else if (value is List) {
            await prefs.setStringList(key, List<String>.from(value));
          }
        }
        if (mounted) {
          showTopRightToast(context, 'Data restored!');
        }
      } catch (e) {
        if (mounted) {
          showTopRightToast(context, 'Invalid backup data');
        }
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        showTopRightToast(context, 'All data has been reset');
      }
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
