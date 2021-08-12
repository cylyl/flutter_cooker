import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_style/dart_style.dart';
import 'package:json_to_dart/model_generator.dart';
import 'package:json_to_dart/syntax.dart';

import 'more_syntax.dart';

class Generator {
  final String rootClassName;
  final bool privateFields;
  List<AbstractClassDefinition> allClasses = [];
  final Map<String, String> sameClassMapping = new HashMap<String, String>();
  late List<Hint> hints;

  Generator(this.rootClassName, [this.privateFields = false, hints]) {
    if (hints != null) {
      this.hints = hints;
    } else {
      this.hints = [];
    }
  }

  Hint? _hintForPath(String path) {
    return this.hints.firstWhereOrNull((h) => h.path == path);
  }

  List<Warning>? generateClassDefinition(
      String className, String path) {return null;  }


  DartCode generateUnsafeDart() {
    List<Warning> warnings =
    generateClassDefinition(rootClassName, "")!;
    // after generating all classes, replace the omited similar classes.
    allClasses.forEach((c) {
      final fieldsKeys = c.fields.keys;
      fieldsKeys.forEach((f) {
        final typeForField = c.fields[f]!;
        if (sameClassMapping.containsKey(typeForField.name)) {
          c.fields[f]!.name = sameClassMapping[typeForField.name]!;
        }
      });
    });
    return new DartCode(
        allClasses.map((c) => c.toString()).join('\n'), warnings);
  }

  DartCode generateDartClasses() {
    final unsafeDartCode = generateUnsafeDart();
    final formatter = new DartFormatter();
    return new DartCode(
        formatter.format(unsafeDartCode.code), unsafeDartCode.warnings);
  }
}
