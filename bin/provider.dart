import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';
import 'package:recase/recase.dart';
import 'generator.dart';

import 'more_syntax.dart';

class ProviderGenerator extends Generator {
  ProviderGenerator(String rootClassName) : super(rootClassName);

  @override
  List<Warning> generateClassDefinition(
      String className, String path) {
    List<Warning> warnings = [];
    ProviderClassDefinition classDefinition =
    new ProviderClassDefinition(className+'Provider', privateFields);
    List<String>  fields = [ (className)+"Bloc", "Widget"];
    fields.forEach((key) {
      TypeDefinition typeDef;
      typeDef = new TypeDefinition(key);
      if (typeDef.name == 'Class') {
        typeDef.name = camelCase(key);
      }
      if (typeDef.name == 'List' && typeDef.subtype == 'Null') {
        warnings.add(newEmptyListWarn('$path/$key'));
      }
      if (typeDef.subtype != null && typeDef.subtype == 'Class') {
        typeDef.subtype = camelCase(key);
      }
      if (typeDef.isAmbiguous) {
        warnings.add(newAmbiguousListWarn('$path/$key'));
      }
      classDefinition.addField(key, typeDef);
    });

    final similarClass = allClasses.firstWhereOrNull((cd) => cd == classDefinition);
    if (similarClass != null) {
      final similarClassName = similarClass.name;
      final currentClassName = classDefinition.name;
      sameClassMapping[currentClassName] = similarClassName;
    } else {
      allClasses.add(classDefinition);
    }
    final dependencies = classDefinition.dependencies;
    dependencies.forEach((dependency) {
      warnings.add(Warning(dependency.toString()+" not implement", path));
    });
    return warnings;
  }
}


class ProviderClassDefinition extends AbstractClassDefinition {
  ProviderClassDefinition(String name, [bool privateFields = false])
      : super(name,privateFields );

  @override
  String get fieldList {
    return fields.keys.map((key) {
      final f = fields[key]!;
      final fieldName =
      fixFieldName(key, typeDef: f, privateField: privateFields);
      final sb = new StringBuffer();
      sb.write('\tfinal ');
      addTypeDef(f, sb);
      sb.write(' $fieldName;');
      return sb.toString();
    }).join('\n');
  }

  @override
  String toString() {

    String bloc = name.replaceAll('Provider', '');
    ReCase blocRecase = ReCase(bloc);
    String imports = '///Generated! do not edit!\n'
        'import \'package:flutter/material.dart\';\n'
        'import \'../bloc/'+ blocRecase.snakeCase + '.dart\';\n\n'
    ;

    String methods = ''
        'static $name of(BuildContext context) =>'
        ' context.dependOnInheritedWidgetOfExactType<$name>();'
        '\n\n'
        '@override\n'
        'bool updateShouldNotify(InheritedWidget oldWidget) {return true;}'
    ;
    return '$imports\n\n'
        'class $name  extends InheritedWidget {\n'
        '$fieldList\n\n'
        '$methods\n\n'
        + (privateFields ? defaultPrivateConstructor : defaultConstructor )
        +': super(child: widget);\n\n'
        '}\n';
  }
}