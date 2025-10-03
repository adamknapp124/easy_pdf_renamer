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

  Future<String> tesseractUnlimitedPower(File imageFile) async {
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

          // create temp file that gets overwritten on each iteration
          final tempDir = Directory.systemTemp;
          final tempImageFile = File('${tempDir.path}/temp_image.png');
          await tempImageFile.writeAsBytes(pageBytes);

          // run tesseract on temp image file
          String text = await tesseractUnlimitedPower(tempImageFile);

          // create target string to find order number then get the index
          String target = 'Order# ';
          final index = text.indexOf(target);

          if (index != -1 && index + target.length + 8 <= text.length) {
            final extractedOrderNumber = text.substring(
              index + target.length,
              index + target.length + 8,
            );
            debugPrint('Extracted Order Number: $extractedOrderNumber');

            final dir = file.parent.path;
            final newPath = "$dir/Packlist_$extractedOrderNumber.pdf";
            debugPrint('Renaming ${file.path} to $newPath');

            final renamedFile = await file.rename(newPath);
            debugPrint('Renamed file path: ${renamedFile.path}');
          } else {
            debugPrint('Order number not found in the text.');
          }

          await page.close();
          await doc.close();

          // debugPrint('path: ${file.path} bytes: ${pageBytes.length}');

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
