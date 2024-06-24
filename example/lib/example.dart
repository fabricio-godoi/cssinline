import 'dart:io';

import 'package:cssinline/cssinline.dart';

void main() {
  final files = Directory('.')
      .listSync(recursive: true)
      .where((e) => e.path.endsWith('.html'))
      .cast<File>();
  HTMLHandle().inlineCss(files);
}
