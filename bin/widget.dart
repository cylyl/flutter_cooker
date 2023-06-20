import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';
import 'package:recase/recase.dart';
import 'generator.dart';
import 'more_syntax.dart';

class WidgetGenerator extends Generator {
  var appDir;

  WidgetGenerator(this.appDir, String rootClassName) : super(rootClassName);

  @override
  List<Warning> generateClassDefinition(
      String className, String path) {
    List<Warning> warnings = [];
    ListClassDefinition classDefinition =
    new ListClassDefinition(appDir, className+'List', privateFields);
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
  var appDir;

  ListClassDefinition(this.appDir, String name, [bool privateFields = false])
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


  List<String> getBlocs(String tname) {
    List<String> res = [];
    String strs = File(appDir + '../../the_hunter_app/lib/bloc_config.dart').readAsStringSync();
    strs = strs.substring(strs.indexOf('getTabViewBlocs'), strs.lastIndexOf('getTabViewBlocs'));

    strs.split('widgetName').forEach((blk) {
      int start = blk.indexOf('==');
      int end = blk.indexOf(')');
      if(end > start && start >= 0) {
        String name = blk.substring(      start    , end).replaceAll('=', '')
            .replaceAll('\'', '');
        if(tname.trim() == name.trim()) {
          blk.split('\n').forEach((line) {
            if(line.contains("//") == false
                && line.contains('add')
            ) {
              res.add(line.substring(line.indexOf('(')+1, line.indexOf('.of')));
            }
          });
        }
      }
    });
    return res;
  }

  @override
  String toString() {

    String name = this.name.replaceAll('List', '');
    ReCase recase = ReCase(name);
    String snakeCase = recase.snakeCase;
    String camelCase = recase.camelCase;
    String clsName = camelCase[0].toUpperCase() + camelCase.substring(1);

    List<String>  blocs = getBlocs(name);

    String code =
        'import \'dart:async\';\n'
            'import \'package:flutter/material.dart\';\n'
            'import \'package:provider/provider.dart\';\n'
            'import \'package:flutter_commons/flutter_commons.dart\';\n'
            'import \'package:flutter_form_bloc/flutter_form_bloc.dart\';\n'
            'import \'package:rest_client/bloc/customer.dart\';\n'
            'import \'package:rest_client/model/request_parameter.dart\';\n'
            'import \'package:the_hunter_app/bloc_config.dart\';\n'
            'import \'package:the_hunter_app/generated/l10n.dart\';\n'
            'import \'package:the_hunter_app/pagination_list.dart\';\n'
            'import \'package:the_hunter_app/layout/main_layout.dart\';\n'
            'import \'package:the_hunter_app/layout/rotate_tab.dart\';\n'
            'import \'package:the_hunter_app/stateful_page.dart\';\n'
            'import \'package:the_hunter_app/main.dart\';\n'
            'import \'package:the_hunter_app/widget/widget_form_bloc.dart\';\n'
            'import \'package:rest_client/model/' + snakeCase + '.dart\';\n'
            'import \'package:rest_client/bloc/' + snakeCase + '.dart\';\n'
            'import \'package:rest_client/bloc/abstract_bloc.dart\';\n'
            '\n'
            'import \'package:rest_client/provider/' + snakeCase + '.dart\';\n'
            '\n'
            '\n'
            '// ignore: must_be_immutable\n'
            'class ' + clsName + 'Widget extends StatefulPage {\n'
            '\n'
            '  ' + clsName + 'Widget({Key? key}) : super(key: key);\n'
            '  late List<AbstractBloc> blocs;\n'
            '  StreamSubscription? streamSubscription;\n'
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
            '  List<TabView> get _tabViews {\n'
            '\n'
            '\n'
            '    blocs = getTabViewBlocs(context, \'' + snakeCase + '\');\n'
            '\n'
            '\n'
            '    return [\n'
            '\n'
            '      ...blocs.map((bloc) {\n'
            '        IconTitle iconTile = iconTitle(context,\n'
            '            bloc.toString().replaceAll(\'Bloc\', \'\').toLowerCase());\n'
            '        return TabView(\n'
            '          label: iconTile.text,\n'
            '          iconData: (iconTile.icon as Icon).icon ,\n'
            '          view: SingleChildScrollView(\n'
            '              child: Column(\n'
            '                children: [\n'
            '                  ...bloc.fields.map((e) => e.builder!),\n'
            '                ],\n'
            '              )),\n'
            '          sideView: [],\n'
            '        );\n'
            '      }),\n'
            '\n'
            '    ];\n'
            '  }\n'
            '\n'
            '  @override\n'
            '  Widget build(BuildContext context) {\n'
            'RequestParameter requestParameter = RequestParameter(\n'
            ' custType: MainState.of(context).user!.userCustType ,\n'
            ' custId:   MainState.of(context).user!.userCustId,\n'
            ');\n'
            '    ' + clsName
            + 'Bloc ' + camelCase + 'Bloc = ' +
            clsName + 'Bloc.of(context);\n'
            '\n'
            '    bool isEditing = ! (' + camelCase + 'Bloc.widgetFormState == WidgetFormState.present);\n'
            '\n'
            '    if (! isEditing) {\n'
            '      if (' + camelCase + 'Bloc.' + camelCase + ' == null)\n'
            '        ' + camelCase + 'Bloc.fetchData(\n'
            '          context,\n'
            '          buildOptions: true,\n'
            '          buildFields: true,\n'
            '        );\n'
            '\n'
            '      CustomerBloc.of(context).fetchData(\n'
            '        context,\n'
            '        buildOptions: true,\n'
            '        buildFields: true,\n'
            '      );\n'
            '    }\n'
            '\n'
            '    List<IconButton> actionMenu = [];\n'
            '\n'
            '    if (isEditing) {\n'
            '//      actionMenu.add(IconButton(\n'
            '//        icon: Icon(\n'
            '//          Icons.check,\n'
            '//        ),\n'
            '//        onPressed: () {\n'
            '//          submit();\n'
            '//        },\n'
            '//      ));\n'
            '    } else {\n'
            '      actionMenu.add(IconButton(\n'
            '        icon: Icon(\n'
            '          Icons.edit,\n'
            '        ),\n'
            '        onPressed: () {\n'
            '          setState(() {\n'
            '            ' + camelCase + 'Bloc.editing();\n'
            '          });\n'
            '        },\n'
            '      ));\n'
            '      actionMenu.add(IconButton(\n'
            '        icon: Icon(\n'
            '          Icons.add_circle,\n'
            '        ),\n'
            '        onPressed: () {\n'
            '          setState(() {\n'
            '            ' + camelCase + 'Bloc.creating();\n'
            '          });\n'
            '        },\n'
            '      ));\n'
            '      actionMenu.add(IconButton(\n'
            '        icon: Icon(\n'
            '          Icons.remove_circle,\n'
            '        ),\n'
            '        onPressed: () {\n'
            '          ScaffoldMessenger.of(context).showSnackBar(SnackBar(\n'
            '            content: Text("TODO : delete " + ' + camelCase + 'Bloc.toString()),\n'
            '            duration: Duration(seconds: 3),\n'
            '          ));\n'
            '        },\n'
            '      ));\n'
            '    }\n'
            '\n'
            '    MainState.of(context).actionMenuRebuild(actionMenu);\n'
            '\n'
            '    return  isEditing ? MainLayout(\n'
            '      right: Container(),\n'
            '//      left:  Container(),\n'
            '      center:  FormWidget(\n'
            '          parent : this,\n'
            '          formName: \'' + snakeCase + '\',\n'
            '          blocs: null,\n'
            '          isCreating: ' + camelCase + 'Bloc.widgetFormState == WidgetFormState.create\n'
            '      ),\n'
            '    )\n'
            '        : MultiProvider( //\n'
            '      //      <--- MultiProvider\n'
            '        providers: [\n'
            '\n';

    if(blocs.length > 1) {
      blocs.forEach((e) {
        ReCase bloc = ReCase(e);
        String cls = bloc.camelCase.trim();
        code +=  '          StreamProvider<'+cls[0].toUpperCase() + cls.substring(1)+'BlocState?>(\n'
            '            initialData: '+bloc.camelCase+'Bloc.of(context).getCurrentState(),\n'
            '            create: (context) => '+bloc.camelCase+'Bloc.of(context).stream,\n'
            '            updateShouldNotify: (_, __) => '+bloc.camelCase+'Bloc.of(context).updateShouldNotify,\n'
            '          ),\n';
      });
    } else {
      code +=  '          StreamProvider<' + clsName + 'BlocState?>(\n'
          '            initialData: ' + camelCase + 'Bloc.getCurrentState(),\n'
          '            create: (context) => ' + camelCase + 'Bloc.stateStream,\n'
          '            updateShouldNotify: (_, __) => ' + camelCase + 'Bloc.updateShouldNotify,\n'
          '          ),\n';
    }

    code +=        '        ],\n'
        '\n';

    if(blocs.length > 0) {
      code += '        child: Consumer' + blocs.length.toString() + '<\n'
      ;

      blocs.forEach((b) {
        code += ReCase(b.toString()).camelCase + 'BlocState,\n';
      });
    } else {
      code += '        child: Consumer<\n'
          '            ' + clsName + 'BlocState\n'
      ;
    }

    code +=
    '        >(\n'
        '            builder: (context,\n';
    if(blocs.length > 0) {

      int index = 1;
      blocs.forEach((b) {
        code += '               s'+ index.toString() +',\n';
        index++;
      });
    } else {
      code +=  '               s1,\n'
      ;
    }

    code +=

        '           child) {\n'
            '              if (s1!.loading) {\n'
            '                return showLoadingDialog();\n'
            '              }\n'
            '\n'
            '              return MainLayout(\n'
            '                  context : context,\n'
            '                  //left: isDisplayDesktop(context) ? Card() : null,\n'
            '                  right: isEditing\n'
            '                      ? Container()\n'
            '                      : PaginationList(\n'
            '                    ///header: null,\n'
            '                    list: ' + camelCase + 'Bloc.' + camelCase + 'BlocState?.list ?? [],\n'
            '                    onRefresh: () async {\n'
            '                      await ' + camelCase + 'Bloc.getStream().first;\n'
            '                    },\n'
            '                    onRowTap: (index) {\n'
            '                      ' + camelCase + 'Bloc.' + camelCase + ' =\n'
            '                          (' + camelCase + 'Bloc.' + camelCase + 'BlocState?.list ?? []).elementAt(index);\n'
            '                      ' + camelCase + 'Bloc.presenting();\n'
            '                      ' + camelCase + 'Bloc.buildField(context);\n'
            '                    },\n'
            '                  ),\n'
            '                  center:  RotateTab(\n'
            '                    tabviews: _tabViews,\n'
            '                    isVertical: isDisplayDesktop(context) ? false : true,\n'
            '                    maxWidth: rotateTabMaxWidth(context),\n'
            '                  ));\n'
            '            }));\n'
            '  }\n'
            '  \n'
            '@override\n'
            'void onSubmitting(FormBlocState<String, String> state) {\n'
            'if(state.currentStep == state.lastStep) {\n'
            'streamSubscription = (blocs.last.getStream() as Stream).listen((event) {\n'
            '' +clsName +'Bloc.of(context).presenting();\n'
            '        setState(() { });\n'
            '       streamSubscription?.cancel();\n'
            ' });\n'
            '       blocs.forEach((bloc) {   bloc.submit(); });\n'
            '      }\n'
            ' }\n'
            '}\n'
    ;
//    print(code);
    return code;
  }
}