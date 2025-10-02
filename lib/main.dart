import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // file picker
    void pickFiles() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // limited files to pdfs
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();

        // for each file...
        for (var file in files) {
          final PdfDocument doc = await PdfDocument.openFile(file.path);
          final page = await doc.getPage(1);
          final PdfPageImage? pageImage = await page.render(
            width: 1080,
            height: 1920,
            format: PdfPageImageFormat.png,
          );

          // get image bytes from png
          final Uint8List pageBytes = pageImage!.bytes;

          debugPrint('path: ${file.path} bytes: ${pageBytes.length}');

          // *** todo: use OCR to extract text from image bytes ***
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
