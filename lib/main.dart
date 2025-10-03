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

  // Runs
  Future<String> _tesseractUnlimitedPower(File imageFile) async {
    try {
      final result = await Process.run('tesseract', [imageFile.path, 'stdout']);

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        return 'Tesseract error: ${result.stderr}';
      }
    } catch (e) {
      return ('Tesseract failed: $e');
    }
  }

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

      // if user selected files
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
          final Uint8List pageBytes = pageImage!.bytes;

          // create temp file that gets overwritten on each iteration
          final tempDir = Directory.systemTemp;
          final tempImageFile = File('${tempDir.path}/temp_image.png');
          await tempImageFile.writeAsBytes(pageBytes);

          // call tesseract on the image
          String text = await _tesseractUnlimitedPower(tempImageFile);

          // create target string to find order number then get the index
          String target = 'Order# ';
          final index = text.indexOf(target);

          // if found, extract the 8 characters after the target string
          if (index != -1 && index + target.length + 8 <= text.length) {
            final extractedOrderNumber = text.substring(
              index + target.length,
              index + target.length + 8,
            );

            // rename the file
            final dir = file.parent.path;
            final newPath = "$dir/Packlist_$extractedOrderNumber.pdf";
            final renamedFile = await file.rename(newPath);
            debugPrint('Renamed to: ${renamedFile.path}');
          } else {
            debugPrint('Order number not found in the text.');
          }

          await page.close();
          await doc.close();
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
