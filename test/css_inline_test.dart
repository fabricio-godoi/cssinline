import 'dart:io';

import 'package:cssinline/cssinline.dart';
import 'package:io/io.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

void main() {
  group('inline validation', () {
    test('genhtml', () async {
      final original = Directory(
          p.joinAll('test/cases/genhtml/html_sample_original'.split('/')));
      final expected = Directory(
          p.joinAll('test/cases/genhtml/html_sample_expected'.split('/')));
      final copy = Directory.systemTemp.createTempSync('cssinline');
      copyPathSync(original.path, copy.path);
      addTearDown(() => copy.deleteSync(recursive: true));

      final tartgetFiles = copy
          .listSync(recursive: true)
          .where((e) => e.path.endsWith('.html'))
          .cast<File>()
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      HTMLHandle().inlineCss(tartgetFiles);

      final expectedFiles = expected
          .listSync(recursive: true)
          .where((e) => e.path.endsWith('.html'))
          .cast<File>()
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      for (int i = 0; i < expectedFiles.length; i++) {
        expect(
          tartgetFiles[0].readAsStringSync(),
          expectedFiles[0].readAsStringSync(),
        );
      }
    });
  });
}
