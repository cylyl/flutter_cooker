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
    strs.replaceAll('\n', '');
    var block = strs.split('widgetName');
    block.forEach((blk) {
      int start = blk.indexOf('==');
      int end = blk.indexOf('else if');
      if(end > start && start >= 0) {
        String name = blk.substring(      start    , blk.indexOf(")")).replaceAll('=', '')
            .replaceAll('\'', '');
        if(tname.toLowerCase().trim() == name.toLowerCase().trim()) {
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

    var modelName = this.name.replaceAll('List', '');
    var modelNameRecase = ReCase(modelName);
    var modelNameCamelCase = modelNameRecase.camelCase;

    String name = this.name.replaceAll('List', '');
    ReCase recase = ReCase(name);
    String snakeCase = recase.snakeCase;
    String camelCase = recase.camelCase;
    String clsName = camelCase[0].toUpperCase() + camelCase.substring(1);

    List<String>  blocs = getBlocs(name);
    print(blocs.length.toString());
    blocs.forEach((e) {print(e); });

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
        + importModel(blocs) +
        'import \'package:rest_client/bloc/' + snakeCase + '.dart\';\n'
        'import \'package:rest_client/bloc/abstract_bloc.dart\';\n'
        'import \'package:rest_client/util/utils.dart\';\n'
        '\n'
        'import \'package:rest_client/provider/' + snakeCase + '.dart\';\n'
        '\n'
        '\n'
          '// ignore: must_be_immutable\n'
          'class '+modelName+'Widget extends StatefulPage {\n'
          '  StreamSubscription? streamSubscription;\n'
          '\n'
          '  '+modelName+'Widget({Key? key}) : super(key: key);\n'
          '\n'
          '  late List<AbstractBloc> blocs;\n'
          '\n'
          '  //bool isEditing = !('+modelNameCamelCase+'Bloc.widgetFormState == WidgetFormState.present);\n'
          '  bool isEditing = false;\n'
          '  int activeTab = 0;\n'
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
          '  @override\n'
          '  void initState() {\n'
          '    super.initState();\n'
          '  }\n'
          '\n'
          '  @override\n'
          '  Widget build(BuildContext context) {\n'
          '    RequestParameter requestParameter = RequestParameter(\n'
          '      custType: MainState.of(context).'+modelNameCamelCase+'!.'+modelNameCamelCase+'CustType,\n'
          '      custId: MainState.of(context).'+modelNameCamelCase+'!.'+modelNameCamelCase+'CustId,\n'
          '    );\n'
          '\n'
          '    return MultiProvider(\n'
          '      providers: [\n'
          '        // ...blocs.map((e) => BlocProvider(\n'
          '        //   create: (_) => e,\n'
          '        // )),\n'

          + genMultiBlocProvider(blocs) +

          '      ],\n'
          '      child: Consumer' +

          blocs.length.toString() + '<'

          + genBlocConsumer(blocs) +

          '>(\n'
          '        builder: (BuildContext context, '

          + genBlocConsumer(blocs, camelCase: true) +

          ', child) {\n'

          + genBlocState(blocs) +

          '          {\n'

          + fetchData(blocs) +
          '            return MultiProvider(\n'
          '              providers: [\n'

          + genMultiStreamProvider(blocs) +

          '              ],\n'
          '              child: Consumer'
              '' + 
          (blocs.length * 2).toString() + '<'

          + genStreamConsumer(blocs) +

          '>(\n'
          '                builder: (context, '
             + genStreamConsumerArgs(blocs) +
          ', child) {\n'

          + genFormBlocState(blocs) +

          '\n'
          '                  List<IconButton> actionMenu = [];\n'
          '\n'
          '                  if (isEditing) {\n'
          '//      actionMenu.add(IconButton(\n'
          '//        icon: Icon(\n'
          '//          Icons.check,\n'
          '//        ),\n'
          '//        onPressed: () {\n'
          '//          submit();\n'
          '//        },\n'
          '//      ));\n'
          '                  } else {\n'
          '                    actionMenu.add(IconButton(\n'
          '                      icon: Icon(\n'
          '                        Icons.edit,\n'
          '                      ),\n'
          '                      onPressed: () {\n'
          '                        setState(() {\n'
          '                          '+modelNameCamelCase+'FormBloc.editing();\n'
          '                        });\n'
          '                      },\n'
          '                    ));\n'
          '                    actionMenu.add(IconButton(\n'
          '                      icon: Icon(\n'
          '                        Icons.add_circle,\n'
          '                      ),\n'
          '                      onPressed: () {\n'
          '                        setState(() {\n'
          '                          '+modelNameCamelCase+'FormBloc.creating();\n'
          '                        });\n'
          '                      },\n'
          '                    ));\n'
          '                    actionMenu.add(IconButton(\n'
          '                      icon: Icon(\n'
          '                        Icons.remove_circle,\n'
          '                      ),\n'
          '                      onPressed: () {\n'
          '                        MainState.of(context)\n'
          '                            .scaffoldKey\n'
          '                            .currentState!\n'
          '                            .showSnackBar(SnackBar(\n'
          '                              content:\n'
          '                                  Text("N/A"),\n'
          '                              duration: Duration(seconds: 3),\n'
          '                            ));\n'
          '                      },\n'
          '                    ));\n'
          '                  }\n'
          '\n'
          '                  MainState.of(context).actionMenuRebuild(actionMenu);\n'
          '\n'
          '                  blocs = isEditing\n'
          '                      ? getEditWizardBlocs(context, \''+modelNameCamelCase+'\')\n'
          '                      : getTabViewBlocs(context, \''+modelNameCamelCase+'\');\n'
          '\n'
          '                 var paginationList;\n'
          '\n'
          + genPaginationIf(blocs) +
          '\n'
          '                  return isEditing\n'
          '                      ? MainLayout(\n'
          '                          center: FormWidget(\n'
          '                              parent: this,\n'
          '                              formName: \''+modelNameCamelCase+'\',\n'
          '                              blocs: null,\n'
          '                              isCreating: '+modelNameCamelCase+'FormBloc.widgetFormState ==\n'
          '                                  WidgetFormState.create),\n'
          '                        )\n'
          '                      : MainLayout(\n'
          '                          context: context,\n'
          '                          center: RotateTab(\n'
          '                            tabviews: [\n'
          '                              ...blocs.map((bloc) {\n'
          '                                IconTitle iconTile = iconTitle(\n'
          '                                    context,\n'
          '                                    bloc\n'
          '                                        .toString()\n'
          '                                        .replaceAll(\'FormBloc\', \'\')\n'
          '                                        .toLowerCase());\n'
          '                                return TabView(\n'
          '                                  label: iconTile.text,\n'
          '                                  iconData: (iconTile.icon as Icon).icon!,\n'
          '                                  view: Container(child: Padding(\n'
          '                                    padding: const EdgeInsets.all(18.0),\n'
          '                                    child: SingleChildScrollView(\n'
          '                                        child: Column(\n'
          '                                          children: [\n'
          '                                            ...bloc.fields.map(((e) => e.builder!)),\n'
          '                                          ],\n'
          '                                        )),\n'
          '                                  )),\n'
          '                                  sideView: [],\n'
          '                                );\n'
          '                              }),\n'
          '                            ],\n'
          '                            isVertical:\n'
          '                                isDisplayDesktop(context) ? false : true,\n'
          '                            maxWidth: rotateTabMaxWidth(context),\n'
          '                               onCreated: (tabController){\n'
          '                                tabController.addListener(() {\n'
          '                                  activeTab = tabController.index;\n'
          '                                  '+modelNameCamelCase+'FormBloc.notify();\n'
          '                                });\n'
          '                              },'
          '                          ),\n'
          '                          //left: isDisplayDesktop(context) ? Card() : null,\n'
          '                          right: isEditing\n'
          '                              ? Container()\n'
          '                              : Container(child: Padding(\n'
          '                            padding: const EdgeInsets.all(18.0),\n'
          '                            child: PaginationList(\n'
          '                              ///header: null,\n'
          '                              list: paginationList,\n'
          '                              onRefresh: () async {\n'
          '                                await '+modelNameCamelCase+'FormBloc.getStream().first;\n'
          '                              },\n'
          '                              onRowTap: (index) {\n'
          '                                '+modelNameCamelCase+'FormBloc.select(context, index);\n'
          '                              },\n'
          '                            ),\n'
          '                          )),\n'
          '                        );\n'
          '                },\n'
          '              ),\n'
          '            );\n'
          '          } else\n'
          '            return Text(\'Err!\');\n'
          '        },\n'
          '      ),\n'
          '    );\n'
          '  }\n'
          '\n'
          '  @override\n'
          '  void onSubmitting(FormBlocState<String, String> state) {\n'
          '    if (state.currentStep == state.lastStep) {\n'
          '      streamSubscription = (blocs.last.getStream() as Stream).listen((event) {\n'
          '        '+modelName+'FormBloc.of(context).presenting();\n'
          '        setState(() {});\n'
          '        streamSubscription?.cancel();\n'
          '      });\n'
          '      blocs.forEach((bloc) {\n'
          '        bloc.submit();\n'
          '      });\n'
          '    }\n'
          '  }\n'
          '}'


    ;
//    print(code);
    return code;
  }


  String genMultiBlocProvider(List<String> blocs) {
    var code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e);
      code +=  '    BlocProvider(\n'
          '            create: (context) => '+bloc.pascalCase.replaceAll('Form', '')+'()'
          '           ..add('+bloc.pascalCase.replaceAll('Form', '')
          .replaceAll('Bloc', '')+'RequestEvent(requestParameter)),\n'
          '          ),\n'
          '    BlocProvider(\n'
          '            create: (context) => '+bloc.pascalCase+'(),'
          '          ),\n';
    });
    return code;
  }

  String genMultiStreamProvider(List<String> blocs) {
    var code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
         code += '      StreamProvider<BlocState<'+bloc.pascalCase+'>>(\n'
          '                  create: (context) => '+bloc.pascalCase+'FormBloc.of(context).stateStream,\n'
          '                  initialData: '+bloc.pascalCase+'FormBloc.of(context).getCurrentState(),\n'
          '                  updateShouldNotify: (_, __) =>\n'
          '                      '+bloc.pascalCase+'FormBloc.of(context).updateShouldNotify,\n'
          '                ),';
    });
    return code;
  }

  String genBlocConsumer(List<String> blocs, {bool camelCase=false}) {
    var code = '';
    if(blocs.length > 0) {

      var ite = blocs.iterator;
      bool hasNext = ite.moveNext();
      for(;hasNext;) {
        var e = ite.current;
        ReCase bloc = ReCase(e.replaceAll('Form', ''));
        code += camelCase ? bloc.camelCase : bloc.pascalCase;
        hasNext = ite.moveNext();
        if(hasNext) {
          code += ',';
        }
      }
    }
    return code;
  }

  String genBlocState(List<String> blocs) {
    var code = '';
    var code2 = '';
    var code3 = 'if (';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += 'var ' + bloc.camelCase + 'BlocState = ' + bloc.camelCase + 'Bloc.state;';

      code2 += 'if (' + bloc.camelCase + 'Bloc.state is ' + bloc.pascalCase + 'DownloadingState) {return showLoadingDialog();}';
    });

    var ite = blocs.iterator;
    bool hasNext = ite.moveNext();
    for(;hasNext;) {
      var e = ite.current;
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code3 +=  bloc.camelCase + 'BlocState is ' + bloc.pascalCase + 'DownloadedState';
      hasNext = ite.moveNext();
      if(hasNext) {
        code3 += ' && ';
      }
    }

    code3 += ')';
    return code+code2+code3;
  }

  String importModel(List<String> blocs) {
    String code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += 'import \'package:rest_client/model/' + bloc.snakeCase + '.dart\';\n';
    });
    return code;
  }

  String genStreamConsumer(List<String> blocs) {
    //''+modelName+'FormBloc, BlocState<'+modelName+'>>'
    var code = '';
    if(blocs.length > 0) {

      var ite = blocs.iterator;
      bool hasNext = ite.moveNext();
      for(;hasNext;) {
        var e = ite.current;
        ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
        code +=  bloc.pascalCase+'FormBloc, BlocState<'+bloc.pascalCase+'>';
        hasNext = ite.moveNext();
        if(hasNext) {
          code += ',';
        }
      }
    }
    return code;
  }

  String genStreamConsumerArgs(List<String> blocs) {
    //''+modelName+'FormBloc, BlocState<'+modelName+'>>'
    var code = '';
    if(blocs.length > 0) {

      var ite = blocs.iterator;
      bool hasNext = ite.moveNext();
      for(;hasNext;) {
        var e = ite.current;
        ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
        code +=  bloc.camelCase+'FormBloc, '+bloc.camelCase+'FormBlocState';
        hasNext = ite.moveNext();
        if(hasNext) {
          code += ',';
        }
      }
    }
    return code;
  }

  String genFormBlocState(List<String> blocs) {
    var code = '';
    var code2 = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      // code += 'var ' + bloc.camelCase + 'BlocState = ' + bloc.camelCase + 'Bloc.state;';

      code2 += 'if (' + bloc.camelCase + 'FormBlocState is ' + bloc.pascalCase + 'FormBlocBuildingState) {return MainLayout(center: showLoadingDialog());}';
    });
    return code+code2;
  }

  String fetchData(List<String> blocs) {
    var code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += bloc.pascalCase +'FormBloc.of(context).fetchData(context, buildFields: true, buildOptions: true);\n';
    });
    return code;
  }

  String genPaginationIf(List<String> blocs) {
    String code = '';
    blocs.forEachIndexed((index, e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += 'if(activeTab == '+index.toString()+') { paginationList = '+bloc.camelCase+'BlocState.list;}';
    });
    return code;
  }
}