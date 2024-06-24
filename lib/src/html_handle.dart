import 'dart:io';
import 'package:cssinline/src/css_handle.dart';
import 'package:html/parser.dart';

import 'package:html/dom.dart';

class HTMLHandle {
  final _cssHandle = const CSSHandle();

  const HTMLHandle();

  /// Loop through a list of html files and remove all css definitions
  /// to inline style configuration for each html element.
  ///
  /// Note: this will update each file in the directory, if needed copy them
  /// first to another directory.
  void inlineCss(Iterable<File> files) {
    // TODO: this code can be improved by async file read/write

    for (final html in files) {
      final document = HtmlParser(html.readAsStringSync()).parse();
      final styleSheets = _cssHandle.handleCssFiles(html.parent, document);

      final allElements = document.querySelectorAll('*');
      for (final element in allElements) {
        if (element.attributes.containsKey('class')) {
          final style = _cssHandle.queryByStyleName(
            element.className.split(' '),
            styleSheets,
          );
          element.attributes.remove('class');
          element.attributes['style'] = _cssHandle.joinStyle(style);
        }
      }

      html.writeAsStringSync(document.outerHtml);
    }
  }

  /// Loop through all elements in the HTML tree (depth first)
  void recursiveCheck(
      Element element, void Function(Element element) callback) {
    for (final child in element.children) {
      callback(element);
      recursiveCheck(child, callback);
    }
  }
}
