import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    void pickFiles() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();

        for (var file in files) {
          // get bytes
          Uint8List bytes = await file.readAsBytes();
          debugPrint('File: ${file.path}, Size: ${bytes.length} bytes');
        }
      } else {
        debugPrint('No files selected');
      }
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Button Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              pickFiles();
            },
            child: Text('Choose files'),
          ),
        ),
      ),
    );
  }
}
