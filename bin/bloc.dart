import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';
import 'package:recase/recase.dart';
import 'generator.dart';

import 'more_syntax.dart';

class BlocGenerator extends Generator {
  BlocGenerator(this.gen, String rootClassName) : super(rootClassName);

  var gen;

  @override
  List<Warning> generateClassDefinition(String className, String path) {
    List<Warning> warnings = [];
    BlocClassDefinition classDefinition =
        new BlocClassDefinition(gen, className + 'FormBloc', privateFields);
    List<String> fields = [
      (className) + "FormBlocState",
      "StreamSubscription<List<$className>>",
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

    final similarClass =
        allClasses.firstWhereOrNull((cd) => cd == classDefinition);
    if (similarClass != null) {
      final similarClassName = similarClass.name;
      final currentClassName = classDefinition.name;
      sameClassMapping[currentClassName] = similarClassName;
    } else {
      allClasses.add(classDefinition);
    }
    final dependencies = classDefinition.dependencies;
    dependencies.forEach((dependency) {
      warnings.add(Warning(dependency.toString() + " not implement", path));
    });
    return warnings;
  }
}

class BlocClassDefinition extends AbstractClassDefinition {
  var gen;

  BlocClassDefinition(this.gen, String name, [bool privateFields = false])
      : super(name, privateFields);

  @override
  String toString() {
    var modelName = name.replaceAll('FormBloc', '');
    var recase = name.replaceAll('FormBloc', '');
    var modelNameRecase = ReCase(modelName);
    var modelNameCamelCase = modelNameRecase.camelCase;
    List<String> blocs = gen.getBlocs(name);
    var _currentState = modelNameRecase.camelCase + 'FormBlocState';
    var streamController = '_' + modelNameCamelCase + 'Controller';
    return ''
            '///Generated! do not edit!\n'
            'import \'dart:async\';\n'
            'import \'package:equatable/equatable.dart\';\n'
            'import \'package:flutter_commons/flutter_commons.dart\';\n'
            'import \'package:flutter/material.dart\';\n'
            'import \'package:flutter_form_bloc/flutter_form_bloc.dart\';\n'
            'import \'package:provider/provider.dart\';\n'
            'import \'package:rest_client/rest_client.dart\';\n'
            'import \'package:rest_client/model/' +
        recase.snakeCase +
        '.dart\';\n'
            'import \'package:rest_client/model/request_parameter.dart\';\n'
            'import \'package:the_hunter_app/bloc_config.dart\';\n' +
        gen.importBloc(blocs) +
        'import \'abstract_bloc.dart\';\n'
            '\n'
            'class ' +
        modelName +
        'FormBloc extends AbstractBloc {\n'
            '  BlocState<' +
        modelName +
        '> ' +
        modelNameCamelCase +
        'FormBlocState = ' +
        modelName +
        'FormBlocInitState();\n'
            '\n'
            '  // StreamSubscription<List<' +
        modelName +
        '>>? streamSubscriptionList' +
        modelName +
        ';\n'
            '  // ' +
        modelName +
        '? ' +
        modelNameCamelCase +
        ';\n'
            '  Map<String, dynamic>? toJson;\n'
            '\n'
            '  ' +
        modelName +
        'FormBloc() {}\n'
            '\n'
            '  final _' +
        modelNameCamelCase +
        'Controller = StreamController<BlocState<' +
        modelName +
        '>>.broadcast();\n'
            '\n'
            '  Stream<BlocState<' +
        modelName +
        '>> get stateStream => _' +
        modelNameCamelCase +
        'Controller.stream;\n'
            '\n'
            '  BlocState<' +
        modelName +
        '> getCurrentState() {\n'
            '    return ' +
        modelNameCamelCase +
        'FormBlocState;\n'
            '  }\n'
            '\n'
            '  notify() {\n'
            '    _' +
        modelNameCamelCase +
        'Controller.add(' +
        modelNameCamelCase +
        'FormBlocState);\n'
            '  }\n'
            '\n'
            '  setState(BlocState<' +
        modelName +
        '> state) {\n'
            '    ' +
        modelNameCamelCase +
        'FormBlocState = state;\n'
            '   if(updateShouldNotify) _' +
        modelNameCamelCase +
        'Controller.add(state);\n'
            '  }\n'
            '\n'
            '  @override\n'
            '  get blocType => ' +
        modelNameCamelCase +
        'FormBlocState.t!;\n'
            '\n'
            '  @override\n'
            '  get json => toJson;\n'
            '\n'
            '  void buildField(BuildContext context, {int step = 0}) {\n'
            '    toJson = ' +
        modelNameCamelCase +
        'FormBlocState.t?.toJson();\n'
            '    super.buildField(context, step: step);\n'
            '  }\n'
            '\n'
            '  void buildFieldAndAdd(BuildContext context, {int step = 0}) {\n'
            '    buildField(context, step: step);\n'
            '    super.addFields(context, step: step);\n'
            '    if (updateShouldNotify && widgetFormState == BlocFormState.display)\n'
            '      notify();\n'
            '  }\n'
            '\n'
            '  loadOption(BuildContext context, bool buildFields, ' +
        modelName +
        ' ' +
        modelNameCamelCase +
        ') {\n'
            '    setState(' +
        modelName +
        'FormBlocBuildingState(' +
        modelNameCamelCase +
        '));\n'
            '    getOption(new ' +
        modelName +
        '()).asStream().listen((' +
        modelNameCamelCase +
        's) {\n'
            '      if (buildFields) {\n'
            '        buildFieldAndAdd(context);\n'
            '      }\n'
            '      setState(' +
        modelName +
        'FormBlocBuildState(' +
        modelNameCamelCase +
        '));\n'
            '    });\n'
            '  }\n'
            '\n'
            '  fetchData(\n'
            '    BuildContext context, {\n'
            '    RequestParameter? requestParameter,\n'
            '    bool buildOptions = false,\n'
            '    bool buildFields = false,\n'
            '  }) {\n'
            '    try {\n'
            '      ' +
        modelName +
        'BlocState state = context.read<' +
        modelName +
        'Bloc>().state;\n'
            '\n'
            '      if (' +
        modelNameCamelCase +
        'FormBlocState.list != null &&\n'
            '          (' +
        modelNameCamelCase +
        'FormBlocState.list ?? []).isNotEmpty &&\n'
            '          super.requestParameter != null &&\n'
            '          super.requestParameter!.equal(requestParameter!)) {\n'
            '        Future.delayed(Duration(milliseconds: 100), () {\n'
            '          if (state is ' +
        modelName +
        'DownloadedState) {\n'
            '            setState(' +
        modelName +
        'FormBlocBuildState(' +
        modelNameCamelCase +
        'FormBlocState.t!));\n'
            '          }\n'
            '        });\n'
            '        return;\n'
            '      }\n'
            '      super.requestParameter = requestParameter;\n'
            '\n'
            '      if (state is ' +
        modelName +
        'DownloadedState) {\n'
            '        if (buildOptions) {\n'
            '          loadOption(context, buildFields, state.list.first);\n'
            '        } else {\n'
            '          setState(' +
        modelName +
        'FormBlocBuildState(state.list.first));\n'
            '        }\n'
            '      }\n'
            '      // RestClient.instance\n'
            '      //     .get' +
        modelName +
        '(requestParameter: requestParameter)\n'
            '      //     .asStream()\n'
            '      //     .listen((dynamic ' +
        modelNameCamelCase +
        's) {\n'
            '      //   if (' +
        modelNameCamelCase +
        's is List) {\n'
            '      //     ' +
        modelNameCamelCase +
        'FormBlocState.list = ' +
        modelNameCamelCase +
        's.cast<' +
        modelName +
        '>();\n'
            '      //   }\n'
            '      //   if (buildOptions) {\n'
            '      //     loadOption(context, buildFields);\n'
            '      //   } else {\n'
            '      //     ' +
        modelNameCamelCase +
        'FormBlocState.loading = false;\n'
            '      //     _' +
        modelNameCamelCase +
        'Controller.add(' +
        modelNameCamelCase +
        'FormBlocState);\n'
            '      //   }\n'
            '      // });\n'
            '    } catch (err, t) {\n'
            '      print(err.toString() + t.toString());\n'
            '    } finally {}\n'
            '  }\n'
            '\n'
            '  @override\n'
            '  submit() {\n'
            '    try {\n'
            '      setState(' +
        modelName +
        'FormBlocSubmittingState(' +
        modelNameCamelCase +
        'FormBlocState.t!));\n'
            '      Stream stream;\n'
            '      if (isCreating) {\n'
            '        //stream = RestClient.instance.' +
        modelNameCamelCase +
        'Create(' +
        modelNameCamelCase +
        ').asStream();\n'
            '        stream = Future.delayed(Duration(seconds: 1), () {\n'
            '          return ' +
        modelNameCamelCase +
        'FormBlocState.t!;\n'
            '        }).asStream();\n'
            '      } else {\n'
            '        ' +
        modelNameCamelCase +
        'FormBlocState.t = ' +
        modelName +
        '.fromJson(toJson!);\n'
            '        //stream = RestClient.instance.' +
        modelNameCamelCase +
        'Put(' +
        modelNameCamelCase +
        ').asStream();\n'
            '        stream = Future.delayed(Duration(seconds: 1), () {\n'
            '          return ' +
        modelNameCamelCase +
        'FormBlocState.t!;\n'
            '        }).asStream();\n'
            '      }\n'
            '      stream.listen((' +
        modelNameCamelCase +
        ') {\n'
            '        ' +
        modelNameCamelCase +
        'FormBlocState.t = ' +
        modelNameCamelCase +
        ';\n'
            '//        super.emitSuccess(canSubmitAgain: true);\n'
            '//        displaying();\n'
            '        setState(' +
        modelName +
        'FormBlocSubmittedState());\n'
            '      });\n'
            '    } catch (err, t) {\n'
            '      print(err.toString() + t.toString());\n'
            '    }\n'
            '//    super.submit();\n'
            '  }\n'
            '\n'
            '  delete() {\n'
            '    try {\n'
            '      setState(' +
        modelName +
        'FormBlocSubmittingState(' +
        modelNameCamelCase +
        'FormBlocState.t!));\n'
            '      RestClient.instance\n'
            '          .' +
        modelNameCamelCase +
        'Delete(' +
        modelNameCamelCase +
        'FormBlocState.t!)\n'
            '          .asStream()\n'
            '          .listen((event) {});\n'
            '      setState(' +
        modelName +
        'FormBlocSubmittedState());\n'
            '    } catch (err) {\n'
            '      print(err.toString());\n'
            '    }\n'
            '  }\n'
            '\n'
            '  static ' +
        modelName +
        'FormBloc of(BuildContext context) {\n'
            '    return BlocProvider.of<' +
        modelName +
        'FormBloc>(context);\n'
            '  }\n'
            '\n'
            '  @override\n'
            '  getStream() {\n'
            '    return stateStream;\n'
            '  }\n'
            '\n'
            '  BlocState<' +
        modelName +
        '> create(BuildContext context, {' +
        modelNameCamelCase +
        '}) {\n'
            '    ' +
        modelNameCamelCase +
        'FormBlocState = ' +
        modelName +
        'FormBlocBuildState(' +
        modelNameCamelCase +
        ' ?? ' +
        modelName +
        '());\n'
            '    creating();\n'
            '    return ' +
        modelNameCamelCase +
        'FormBlocState;\n'
            '  }\n'
            '\n'
            '  void select(BuildContext context, int index) {\n'
            '    var state = ' +
        modelName +
        'Bloc.of(context).state;\n'
            '    if (state is ' +
        modelName +
        'DownloadedState) {\n'
            '      ' +
        modelNameCamelCase +
        'FormBlocState.t = state.list.elementAt(index);\n'
            '      setState(' +
        modelName +
        'FormBlocBuildingState(' +
        modelNameCamelCase +
        'FormBlocState.t!));\n'
            '      buildFieldAndAdd(context);\n'
            '      setState(' +
        modelName +
        'FormBlocBuildState(' +
        modelNameCamelCase +
        'FormBlocState.t!));\n'
            '    }\n'
            '  }\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'FormBlocInitState extends BlocState<' +
        modelName +
        '> {\n'
            '  ' +
        modelName +
        'FormBlocInitState() : super(true, false, null);\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'FormBlocBuildingState extends BlocState<' +
        modelName +
        '> {\n'
            '  ' +
        modelName +
        'FormBlocBuildingState(' +
        modelName +
        ' ' +
        modelNameCamelCase +
        ') : super(false, true, null, t: ' +
        modelNameCamelCase +
        ');\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'FormBlocBuildState extends BlocState<' +
        modelName +
        '> {\n'
            '  ' +
        modelName +
        'FormBlocBuildState(' +
        modelName +
        ' ' +
        modelNameCamelCase +
        ') : super(false, false, null, t: ' +
        modelNameCamelCase +
        ');\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'FormBlocSubmittingState extends BlocState<' +
        modelName +
        '> {\n'
            '  ' +
        modelName +
        'FormBlocSubmittingState(' +
        modelName +
        ' ' +
        modelNameCamelCase +
        ') : super(false, true, null, t: ' +
        modelNameCamelCase +
        ');\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'FormBlocSubmittedState extends BlocState<' +
        modelName +
        '> {\n'
            '  ' +
        modelName +
        'FormBlocSubmittedState() : super(false, false, null);\n'
            '}\n'
            '\n'
            'abstract class ' +
        modelName +
        'BlocEvent extends Equatable {}\n'
            '\n'
            'class ' +
        modelName +
        'RequestEvent extends ' +
        modelName +
        'BlocEvent {\n'
            '  final RequestParameter? requestParameter;\n'
            '\n'
            '  ' +
        modelName +
        'RequestEvent(this.requestParameter);\n'
            '\n'
            '  @override\n'
            '  List<Object?> get props => [];\n'
            '}\n'
            'class ' +
        modelName +
        'CreateEvent extends ' +
        modelName +
        'BlocEvent {\n'
            '  final RequestParameter? requestParameter;\n'
            '\n'
            '  ' +
        modelName +
        'CreateEvent(this.requestParameter);\n'
            '\n'
            '  @override\n'
            '  List<Object?> get props => [];\n'
            '}\n'
            'abstract class ' +
        modelName +
        'BlocState {}\n'
            '\n'
            'class ' +
        modelName +
        'InitState extends ' +
        modelName +
        'BlocState {}\n'
            '\n'
            'class ' +
        modelName +
        'DownloadingState extends ' +
        modelName +
        'BlocState {}\n'
            '\n'
            'class ' +
        modelName +
        'DownloadedState extends ' +
        modelName +
        'BlocState {\n'
            '  final List<' +
        modelName +
        '> list;\n'
            '\n'
            '  ' +
        modelName +
        'DownloadedState(this.list);\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'ErrorState extends ' +
        modelName +
        'BlocState {\n'
            '  var e;\n'
            '\n'
            '  ' +
        modelName +
        'ErrorState(this.e);\n'
            '}\n'
            '\n'
            'class ' +
        modelName +
        'Bloc extends Bloc<' +
        modelName +
        'BlocEvent, ' +
        modelName +
        'BlocState> {\n'
            '  ' +
        '  '+modelName+'Bloc() : super('+modelName+'InitState()) {\n'
        '    on<'+modelName+'RequestEvent>((event, emit) async {\n'
        '      emit('+modelName+'DownloadingState());\n'
        '      try {\n'
        '        List<'+modelName+'> '+modelNameCamelCase+'s = await RestClient.instance\n'
        '            .get'+modelName+'(requestParameter: event.requestParameter);\n'
        '        emit('+modelName+'DownloadedState('+modelNameCamelCase+'s));\n'
        '      } on Exception catch (e) {\n'
        '        emit('+modelName+'ErrorState(e));\n'
        '      }\n'
        '    });\n'
        '    on<'+modelName+'CreateEvent>((event, emit) async {\n'
        '      try {\n'
        '        List<'+modelName+'> customers = ['+modelName+'()];\n'
        '        emit('+modelName+'DownloadedState(customers));\n'
        '      } on Exception catch (e) {\n'
        '        emit('+modelName+'ErrorState(e));\n'
        '      }\n'
        '    });\n'
        '  }\n'
            '\n'
            '  static ' +
        modelName +
        'Bloc of(BuildContext context) {\n'
            '    return Provider.of<' +
        modelName +
        'Bloc>(context, listen: false);\n'
            '  }\n'
            '}';
  }
}
