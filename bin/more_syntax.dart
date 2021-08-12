import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_to_dart/syntax.dart';
import 'package:json_to_dart/helpers.dart';

class TypeDefinitionP extends TypeDefinition {
  TypeDefinitionP(String name) : super(name);
}


abstract class AbstractClassDefinition {

  final String _name;
  final bool _privateFields;
  final Map<String, TypeDefinition> fields = new Map<String, TypeDefinition>();

  String get name => _name;
  bool get privateFields => _privateFields;

  List<Dependency> get dependencies {
    final List<Dependency> dependenciesList = [];
    final keys = fields.keys;
    keys.forEach((k) {
      final f = fields[k]!;
      if (!f.isPrimitive) {
        dependenciesList.add(new Dependency(k, f));
      }
    });
    return dependenciesList;
  }

  AbstractClassDefinition(this._name, [this._privateFields = false]);

  bool operator ==(other) {
    if (other is AbstractClassDefinition) {
      AbstractClassDefinition otherClassDef = other;
      return this.isSubsetOf(otherClassDef) && otherClassDef.isSubsetOf(this);
    }
    return false;
  }

  bool isSubsetOf(AbstractClassDefinition other) {
    final List<String> keys = this.fields.keys.toList();
    final int len = keys.length;
    for (int i = 0; i < len; i++) {
      TypeDefinition? otherTypeDef = other.fields[keys[i]];
      if (otherTypeDef != null) {
        TypeDefinition? typeDef = this.fields[keys[i]];
        if (typeDef != otherTypeDef) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  hasField(TypeDefinition otherField) {
    return fields.keys
        .firstWhereOrNull((k) => fields[k] == otherField) !=
        null;
  }

  addField(String name, TypeDefinition typeDef) {
    fields[name] = typeDef;
  }

  void addTypeDef(TypeDefinition typeDef, StringBuffer sb) {
    sb.write('${typeDef.name}');
    if (typeDef.subtype != null) {
      sb.write('<${typeDef.subtype}>');
    }
  }

  String get fieldList {
    return fields.keys.map((key) {
      final f = fields[key]!;
      final fieldName =
      fixFieldName(key, typeDef: f, privateField: privateFields);
      final sb = new StringBuffer();
      sb.write('\t');
      addTypeDef(f, sb);
      sb.write(' $fieldName;');
      return sb.toString();
    }).join('\n');
  }

  String get _gettersSetters {
    return fields.keys.map((key) {
      final f = fields[key]!;
      final publicFieldName =
      fixFieldName(key, typeDef: f, privateField: false);
      final privateFieldName =
      fixFieldName(key, typeDef: f, privateField: true);
      final sb = new StringBuffer();
      sb.write('\t');
      addTypeDef(f, sb);
      sb.write(
          ' get $publicFieldName => $privateFieldName;\n\tset $publicFieldName(');
      addTypeDef(f, sb);
      sb.write(' $publicFieldName) => $privateFieldName = $publicFieldName;');
      return sb.toString();
    }).join('\n');
  }

  String get defaultPrivateConstructor {
    final sb = new StringBuffer();
    sb.write('\t$name({');
    var i = 0;
    var len = fields.keys.length - 1;
    fields.keys.forEach((key) {
      final f = fields[key]!;
      final publicFieldName =
      fixFieldName(key, typeDef: f, privateField: false);
      addTypeDef(f, sb);
      sb.write(' $publicFieldName');
      if (i != len) {
        sb.write(', ');
      }
      i++;
    });
    sb.write('}) {\n');
    fields.keys.forEach((key) {
      final f = fields[key]!;
      final publicFieldName =
      fixFieldName(key, typeDef: f, privateField: false);
      final privateFieldName =
      fixFieldName(key, typeDef: f, privateField: true);
      sb.write('this.$privateFieldName = $publicFieldName;\n');
    });
    sb.write('})');
    return sb.toString();
  }

  String get defaultConstructor {
    final sb = new StringBuffer();
    sb.write('\t$name({');
    var i = 0;
    var len = fields.keys.length - 1;
    fields.keys.forEach((key) {
      final f = fields[key]!;
      final fieldName =
      fixFieldName(key, typeDef: f, privateField: privateFields);
      sb.write('this.$fieldName');
      if (i != len) {
        sb.write(', ');
      }
      i++;
    });
    sb.write('})');
    return sb.toString();
  }

//  String toString() {}
}
