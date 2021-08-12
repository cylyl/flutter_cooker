import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';
import 'package:recase/recase.dart';
import 'generator.dart';

import 'more_syntax.dart';

class WidgetGenerator extends Generator {
  WidgetGenerator(String rootClassName) : super(rootClassName);

  @override
  List<Warning> generateClassDefinition(
      String className, String path) {
    List<Warning> warnings = [];
    ListClassDefinition classDefinition =
    new ListClassDefinition(className+'List', privateFields);
    List<String>  fields = [
      "List<"+(className)+">",
      "RefreshCallback"
    ];
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


class ListClassDefinition extends AbstractClassDefinition {
  ListClassDefinition(String name, [bool privateFields = false])
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

    String name = this.name.replaceAll('List', '');
    ReCase recase = ReCase(name);

    return
      'import \'package:flutter/material.dart\';\n'
          'import \'package:provider/provider.dart\';\n'
          'import \'package:flutter_commons/flutter_commons.dart\';\n'
          'import \'package:flutter_form_bloc/flutter_form_bloc.dart\';\n'
          'import \'package:the_hunter_app/generated/l10n.dart\';\n'
          'import \'package:the_hunter_app/pagination_list.dart\';\n'
          'import \'package:the_hunter_app/layout/main_layout.dart\';\n'
          'import \'package:the_hunter_app/layout/rotate_tab.dart\';\n'
          'import \'package:the_hunter_app/stateful_page.dart\';\n'
          'import \'package:the_hunter_app/main.dart\';\n'
          'import \'package:the_hunter_app/widget/widget_form_bloc.dart\';\n'
          'import \'package:rest_client/model/'+ recase.snakeCase + '.dart\';\n'
          'import \'package:rest_client/bloc/'+ recase.snakeCase + '.dart\';\n'
          'import \'package:rest_client/bloc/abstract_bloc.dart\';\n'
          '\n'
          'import \'package:rest_client/provider/'+ recase.snakeCase + '.dart\';\n'
          '\n'
          '// ignore: must_be_immutable\n'
          'class '+name+'Widget extends StatefulPage {\n'
          '  '+name+'Widget({Key? key}) : super(key: key);\n'
          '  List<AbstractBloc> blocs;\n'
          '\n'
          '\n'
          '\n'
          '  void submit() {\n'
          '    blocs.forEach((bloc) {\n'
          '      bloc.submit();\n'
          '    });\n'
          '  }\n'
          '\n'
          '  @override\n'
          '  void setState(VoidCallback fn) {\n'
          '    super.setState(() {\n'
          '      fn.call();\n'
          '    });\n'
          '  }\n'
          '\n'
          '  @override\n'
          '  void dispose() {\n'
          '    super.dispose();\n'
          '  }\n'
          '\n'
          '  List<TabView>  get _tabViews {\n'
          '    return  [\n'
          '      TabView(\n'
          '        label: S.of(context).'+ recase.camelCase + ',\n'
          '        iconData: Icons.tab,\n'
          '        view: FormBlocListener<'+name+'Bloc, String, String>(\n'
          '            onSubmitting: (context, state) {\n'
          '              showLoadingDialog();\n'
          '            },\n'
          '            onSuccess: (context, state) {\n'
          '              setState(() {});\n'
          '            },\n'
          '            onFailure: (context, state) {\n'
          '              hideLoadingDialog();\n'
          '            },\n'
          '            child: SingleChildScrollView(\n'
          '                child: Column(\n'
          '                  children: [\n'
          '                    ...'+name+'Bloc.of(context).fields.map((e) => e.builder),\n'
          '                  ],\n'
          '                ))),\n'
          '        sideView: [],\n'
          '      ),\n'
          '    ];\n'
          '  }\n'
          '\n'
          '  @override\n'
          '  Widget build(BuildContext context) {\n'
          '    '+name+'Bloc '+ recase.camelCase + 'Bloc = '+name+'Bloc.of(context);\n'
          '\n'
          '    bool isEditing = '+ recase.camelCase + 'Bloc.isEditing ||'+ recase.camelCase + 'Bloc.isCreating;\n'
          '\n'
          '    if(isEditing) {\n'
          '      if (blocs == null ) {\n'
          '        blocs = lookupBlocs(context, \''+ recase.snakeCase + '\');\n'
          '        if('+ recase.camelCase + 'Bloc.isEditing) {\n'
          '          blocs.forEach((bloc) {\n'
          '            bloc.isEditing = '+ recase.camelCase + 'Bloc.isEditing;\n'
          '            bloc.fetchData(\n'
          '              context,\n'
          '              buildOptions: true,\n'
          '              buildFields: false,\n'
          '            );\n'
          '          });\n'
          '        } else {\n'
          '          '+ recase.camelCase + 'Bloc.create(context);\n'
          '        }\n'
          '      }\n'
          '    } else {\n'
          '      if ('+ recase.camelCase + 'Bloc.'+ recase.camelCase + ' == null)\n'
          '        '+ recase.camelCase + 'Bloc.fetchData(\n'
          '          context,\n'
          '          buildOptions: true,\n'
          '          buildFields: true,\n'
          '        );\n'
          '    }\n'
          '\n'
          '    List<IconButton> actionMenu = [];\n'
          '\n'
          '    if (isEditing) {\n'
          '      actionMenu.add(IconButton(\n'
          '        icon: Icon(\n'
          '          Icons.check,\n'
          '        ),\n'
          '        onPressed: () {\n'
          '          submit();\n'
          '        },\n'
          '      ));\n'
          '    } else {\n'
          '      actionMenu.add(IconButton(\n'
          '        icon: Icon(\n'
          '          Icons.edit,\n'
          '        ),\n'
          '        onPressed: () {\n'
          '          setState(() {\n'
          '            '+ recase.camelCase + 'Bloc.isEditing = true;\n'
          '            '+ recase.camelCase + 'Bloc.isCreating = false;\n'
          '          });\n'
          '        },\n'
          '      ));\n'
          '      actionMenu.add(IconButton(\n'
          '        icon: Icon(\n'
          '          Icons.add_circle,\n'
          '        ),\n'
          '        onPressed: () {\n'
          '          setState(() {\n'
          '            '+ recase.camelCase + 'Bloc.isCreating = true;\n'
          '            '+ recase.camelCase + 'Bloc.isEditing = true;\n'
          '          });\n'
          '        },\n'
          '      ));\n'
          '      actionMenu.add(IconButton(\n'
          '        icon: Icon(\n'
          '          Icons.remove_circle,\n'
          '        ),\n'
          '        onPressed: () {\n'
          '          MainState.of(context).scaffoldKey.currentState.showSnackBar(SnackBar(\n'
          '            content: Text("TODO : delete " + '+ recase.camelCase + 'Bloc.toString()),\n'
          '            duration: Duration(seconds: 3),\n'
          '          ));\n'
          '        },\n'
          '      ));\n'
          '    }\n'
          '\n'
          '    MainState.of(context).actionMenuRebuild(actionMenu);\n'
          '\n'
          '    return StreamProvider<'+name+'BlocState?>(\n'
          '\n'
          '        initialData: '+ recase.camelCase + 'Bloc.getCurrentState(),\n'
          '        create:  (context) => '+ recase.camelCase + 'Bloc.'+ recase.camelCase + 'Stream,\n'
          '        updateShouldNotify: (_,__) => '+ recase.camelCase + 'Bloc.updateShouldNotify ,\n'
          '\n'
          '        child: Consumer<'+name+'BlocState?>(\n'
          '            builder: (context,  snapshot, child) {\n'
          '              if (snapshot.loading) {\n'
          '                return showLoadingDialog();\n'
          '              }\n'
          '\n'
          '              return MainLayout(\n'
          '                  right: isDisplayDesktop(context) ? Card() : null,\n'
          '                  left: '+ recase.camelCase + 'Bloc.isCreating ? Container()\n'
          '                      : PaginationList(\n'
          '                    ///header: null,\n'
          '                    list: '+ recase.camelCase + 'Bloc.'+ recase.camelCase + 'BlocState.list,\n'
          '                    onRefresh: () async {\n'
          '                      await '+ recase.camelCase + 'Bloc.getStream().first;\n'
          '                    },\n'
          '                    onRowTap: (index) {\n'
          '                      '+ recase.camelCase + 'Bloc.'+ recase.camelCase + ' =\n'
          '                          '+ recase.camelCase + 'Bloc.'+ recase.camelCase + 'BlocState.list.elementAt(index);\n'
          '                      '+ recase.camelCase + 'Bloc.isCreating = false;\n'
          '                      '+ recase.camelCase + 'Bloc.isEditing  = false;\n'
          '                      '+ recase.camelCase + 'Bloc.buildField(context);\n'
          '                    },\n'
          '                  ),\n'
          '                  center: isEditing ? FormWidget(\n'
          '                      blocs: blocs,\n'
          '                      isCreating: '+ recase.camelCase + 'Bloc.isCreating\n'
          '                  )\n'
          '                      : RotateTab(\n'
          '                    tabviews: _tabViews,\n'
          '                    isVertical: isDisplayDesktop(context) ? false : true,\n'
          '                    maxWidth: rotateTabMaxWidth(context),\n'
          '                  )\n'
          '              );\n'
          '            }\n'
          '        )\n'
          '    );\n'
          '  }\n'
          '}\n'
          '\n'
    ;
  }
}