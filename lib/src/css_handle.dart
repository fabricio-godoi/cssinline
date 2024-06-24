import 'dart:io';
import 'package:csslib/visitor.dart';
import 'package:html/dom.dart';

import 'package:path/path.dart' as p;
import 'package:csslib/parser.dart' as css;

final Map<String, StyleSheet> cssFiles = {};

/// {@template cssinline:csshandle}
/// Methods and handles for CSS
/// {@endtemplate}
class CSSHandle {
  /// {@macro cssinline:csshandle}
  const CSSHandle();

  /// Parse `link` to get CSS data from file
  StyleSheet? _handleCssByLinkTag(Element element, Directory dir) {
    StyleSheet? styleSheet;
    if (element.attributes['type'] == 'text/css' &&
        (element.attributes['href']?.isNotEmpty ?? false)) {
      final href = element.attributes['href']!;
      final cssPath =
          p.isAbsolute(href) ? href : p.normalize(p.join(dir.path, href));

      if (cssFiles.containsKey(cssPath)) {
        styleSheet = cssFiles[cssPath];
      } else {
        try {
          styleSheet = css.parse(File(cssPath).readAsStringSync());
          cssFiles[cssPath] = styleSheet;
        } catch (e, stk) {
          print('Could not parse CSS from file $cssPath: $e\n$stk');
        }
      }
    }
    return styleSheet;
  }

  /// Parse `style` tag to get CSS data
  StyleSheet? _handleCssByStyleTag(Element element) {
    StyleSheet? styleSheet;
    try {
      styleSheet = css.parse(element.outerHtml);
    } catch (e, stk) {
      print(
        'Could not parse CSS from style tag $e\n$stk',
      );
    }
    return styleSheet;
  }

  /// Parse `head` for CSS definitions, removing the element from html.
  ///
  /// It returns a list of [StyleSheet] parsed in sequencial order given in the
  /// `head`. The [cssFiles] are updated with all css parsed from files.
  ///
  /// Currently supporting `link` and `style` html tags.
  List<StyleSheet> handleCssFiles(Directory dir, Document document) {
    final styleSheets = <StyleSheet>[];
    List<Element>? elements = document.head?.querySelectorAll('style,link');
    if (elements == null) return styleSheets;

    // Loop through styles sequentially to prevent some style substituion
    for (final element in elements) {
      StyleSheet? styleSheet;
      switch (element.localName) {
        case 'link':
          styleSheet = _handleCssByLinkTag(element, dir);
          break;
        case 'style':
          styleSheet = _handleCssByStyleTag(element);
          break;
      }

      if (styleSheet != null) {
        element.remove(); // remove from html
        styleSheets.add(styleSheet);
      }
    }

    return styleSheets;
  }

  /// Given a style map, join it as a single string for inline style
  String joinStyle(Map<String, dynamic> style) {
    return style.entries.map((e) {
      if (e.value is List) {
        return '${e.key}: ${(e.value as List).map((e) => e.toString()).join(', ')};';
      } else if (e.value is Map) {
        return '${e.key}: ${joinStyle((e.value as Map).cast<String, dynamic>())};';
      } else {
        return '${e.key}: ${e.value};';
      }
    }).join(' ');
  }

  /// Try get class name by quering its class name
  ///
  /// Check pattern matching specification for more information about class naming:
  /// https://www.w3.org/TR/CSS22/selector.html#pattern-matching
  Map<String, dynamic> queryByStyleName(
    List<String> selectors,
    Iterable<StyleSheet>? styleSheets,
  ) {
    final Map<String, dynamic> styles = {}; // Results (styles).
    if (styleSheets == null || styleSheets.isEmpty) return styles;

    // Collect the rules of the specified selectors from [styleSheets].
    for (StyleSheet styleSheet in styleSheets) {
      final List<RuleSet> rules =
          styleSheet.topLevels.whereType<RuleSet>().where((RuleSet ruleSet) {
        if (ruleSet.selectorGroup == null) return false;

        return (ruleSet.selectorGroup!.selectors.where(
          (Selector selector) {
            return (selector.simpleSelectorSequences.where(
              (SimpleSelectorSequence simpleSelectorSequence) {
                return selectors.contains(
                  simpleSelectorSequence.simpleSelector.name,
                );
              },
            ).isNotEmpty);
          },
        ).isNotEmpty);
      }).toList();

      // Collect all the styles of the specified selectors.
      for (final RuleSet rule in rules) {
        for (final Declaration declaration
            in rule.declarationGroup.declarations.whereType<Declaration>()) {
          final Iterable<Expression> expressions =
              (declaration.expression as Expressions)
                  .expressions
                  .whereType<Expression>();

          // Sample how to get each expression (may be useful in the future)
          // final String value = expressions.fold('', (String value, Expression expression) {
          //     final LiteralTerm term = (expression as LiteralTerm);
          //     return (value + (expression.span?.text ?? ''));
          // });

          final value = expressions.map<String>((e) => e.span!.text).join();

          styles.addAll({
            declaration.property: value,
          });
        }
      }
    }

    return styles;
  }

  /// Return all [RuleSet] from [StyleSheet]
  Iterable<RuleSet> getRuleSetAll(StyleSheet styleSheet) {
    return styleSheet.topLevels.whereType<RuleSet>();
  }

  /// Get the "key" of a [RuleSet]
  String ruleSetKeyRaw(RuleSet ruleSet) {
    return ruleSet.span.text;
  }

  /// Get the raw value of a [RuleSet]
  String ruleSetValueRaw(RuleSet ruleSet) {
    return ruleSet.declarationGroup.declarations
        .whereType<Declaration>()
        .map<String>((e) => '${e.span.text};')
        .join(' ');
  }
}
