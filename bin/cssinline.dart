import 'dart:io';

import 'package:cssinline/cssinline.dart';
import 'package:path/path.dart' as p;

/// Process success code
const successCode = 0;

/// Process error code
const errorCode = 1;

const String help = '''
Command line interface to interact with CSS inline tools.

Usage: cssinline <directory> [arguments]

Options:
-h, --help            Print this usage information.
-o, --output          Desired output directory.

Example:
  # Inline content in current directory;
  cssinline

  # Inline content from current directory and output it to `otherDir`;
  cssinline --output="./otherDir"

  # Inlined content from `targetDir` and output it to `otherDir`;
  cssinline targetDir -o otherDir
  cssinline targetDir --output="./otherDir"
''';

int main(List<String> arguments) {
  final args = [...arguments];
  bool showHelp = args.any((a) => a == '-h' || a == '--help');
  if (showHelp) {
    print(help);
    return successCode;
  }

  String? outputPath;
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('-o') || arg.startsWith('--output')) {
      if (arg.contains('=')) {
        outputPath = arg.split('=').last;
      } else if ((i + 1) < args.length) {
        outputPath = args[i + 1];
        args.removeAt(i + 1);
      }
      args.removeAt(i);
      break;
    }
  }

  Directory? output;
  if (outputPath != null) {
    outputPath = p.absolute(p.normalize(outputPath));
    output = Directory(outputPath);
    if (output.existsSync() && output.listSync().isNotEmpty) {
      print(
        'Warning: Selected output directory is not empty, aborting\n$output',
      );
      return errorCode;
    }
  }

  String targetDir = args.isEmpty ? '.' : args.first;
  Directory target = Directory(targetDir);
  if (!target.existsSync()) {
    print('Could not find target directory `$target`');
    return errorCode;
  }

  try {
    inline(target, output: output);
  } catch (e, stk) {
    print('Error: could not inline all files: $e\n$stk');
    return errorCode;
  }

  return successCode;
}

/// Copy one dir to another folder
void copyDirSync(Directory from, Directory to) {
  if (!from.existsSync() || p.absolute(from.path) == p.absolute(to.path)) {
    return;
  }

  to.createSync(recursive: true);
  for (final file in from.listSync(recursive: true)) {
    final copyTo = p.join(to.path, p.relative(file.path, from: from.path));
    if (file is Directory) {
      Directory(copyTo).createSync(recursive: true);
    } else if (file is File) {
      File(file.path).copySync(copyTo);
    } else if (file is Link) {
      Link(copyTo).createSync(file.targetSync(), recursive: true);
    }
  }
}

/// Perform inline operation
int inline(Directory target, {Directory? output}) {
  if (output != null) {
    /// Copy files to output
    copyDirSync(target, output);
    target = output;
  }

  final files = target.listSync(recursive: true, followLinks: false);
  final htmlFiles = <File>[];
  htmlFiles.addAll(files
      .where((f) => p.extension(f.path) == '.html' && f is File)
      .map((e) => e as File));

  HTMLHandle().inlineCss(htmlFiles);

  return successCode;
}
