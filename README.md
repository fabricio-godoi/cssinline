# cssinline

[![cssinline](https://img.shields.io/pub/v/cssinline.svg)](https://pub.dev/packages/cssinline)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

Project to provide helpful handlers to embed CSS styles into HTML elements style attribute.

This library is designed to help embed any HTML page into environments that do not support CSS loading for any security reason, such as:

- Sending emails;
- Uploading HTML in third-party web pages;

### Features

- Built-in with pure dart code and technology;
- CSS parser and query selector;
- HTML handler for inlining CSS into style attributes;
- Command-line tool to make it easy to use in the terminal;

## Usage

It is possible to use this project as a dependency package in your project or as a command-line tool.

### Project dependency

To use this tool as a library in your project, install it with:

```sh
dart pub add cssinline
```

Usage example:

```dart
import 'package:cssinline/cssinline.dart';

final files = Directory('.')
          .listSync(recursive: true)
          .where((e) => e.path.endsWith('.html'))
          .cast<File>();
HTMLHandle().inlineCss(files);
```

### Command-line interface

To use this as a command-line tool, install it with:

**_Linux/MacOS:_**

```sh
dart pub global activate cssinline

## Add 	$HOME/.pub-cache/bin to your environment if not set (bash)
echo 'export PATH="$PATH;$HOME/.pub-cache/bin"' >> $HOME/.bashrc
```

**_Windows:_**

```sh
dart pub global activate cssinline

# Update Windows user PATH with pub global binaries
setx path "%path%;%LOCALAPPDATA%\Pub\Cache\bin"
```

Check its usage with `cssinline --help`:

```sh
Command line interface to interact with CSS inline tools.

Usage: cssinline <directory> [arguments]

Options:
-h, --help Print this usage information.
-o, --output Desired output directory.

Example: # Inline content in current directory;
cssinline

    # Inline content from current directory and output it to `otherDir`;
    cssinline --output="./otherDir"

    # Inlined content from `targetDir` and output it to `otherDir`;
    cssinline targetDir -o otherDir
    cssinline targetDir --output="./otherDir"

```

## Disclaimer

This project was created as a side project hobby and will be maintained and improved as long as the community helps to improve it.

Code contributions are always welcome to improve this tool, and will be merged as soon as possible.

## License

[MIT](LICENSE)
