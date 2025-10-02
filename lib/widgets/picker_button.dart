import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerButton extends StatelessWidget {
  final String buttonText;
  final void Function(FilePickerResult?) onFilePicked;

  const FilePickerButton({
    super.key,
    this.buttonText = "Pick a file",
    required this.onFilePicked,
  });

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    onFilePicked(result);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: _pickFile, child: Text(buttonText));
  }
}
