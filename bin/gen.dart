import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart'
    show dirname, join, normalize, basenameWithoutExtension;
import 'package:dart_style/dart_style.dart';
import 'package:json_to_dart/model_generator.dart';
import 'package:recase/recase.dart';
import 'package:mysql1/mysql1.dart';

import 'bloc.dart';
import 'widget.dart';
import 'provider.dart';

class Gen {
  // static final appDir = dirname(_scriptPath());
  final appDir;
  var jsonDir;
  var modelDir;
  var blocDir;
  var providerDir;
  var listDir;

  Gen(this.appDir) {
    jsonDir = join(appDir, '../json');
    modelDir = join(appDir, 'model');
    blocDir = join(appDir, 'bloc');
    providerDir = join(appDir, 'provider');
    listDir = join(appDir, 'widget');
  }

  static String _scriptPath() {
    var script = Platform.script.toString();
    if (script.startsWith("file://")) {
      script = script.substring(7);
    } else {
      final idx = script.indexOf("file:/");
      script = script.substring(idx + 5);
    }
    return script;
  }

  void genModel() {
    Directory dir = Directory(jsonDir);
    dir.list(recursive: false).forEach((f) {
      ReCase reCase = new ReCase(basenameWithoutExtension(f.path));
      String className = reCase.pascalCase;
      ModelGenerator modelGenerator = new ModelGenerator(className);

      final filePath = (join(jsonDir, reCase.originalText + '.json'));

      print('processing $filePath');
      final jsonRawData = new File(filePath).readAsStringSync();
      DartCode dartCode = modelGenerator.generateDartClasses(jsonRawData);
      new File('$modelDir/' + reCase.snakeCase + '.dart')
          .writeAsString(dartCode.code);
    });
  }

  void genProvider() {
    ProviderGenerator generator;
    Directory dir = Directory(modelDir);
    dir.list(recursive: false).forEach((f) {
      if (f.path.endsWith('request_parameter.dart') ||
          f.path.endsWith('uresponse.dart')) {
      } else {
        ReCase reCase = new ReCase(basenameWithoutExtension(f.path));
        String className = reCase.pascalCase;
        generator = ProviderGenerator(className);
        new File(providerDir + '/' + reCase.snakeCase + '.dart')
            .writeAsString(generator.generateDartClasses().code);
      }
    });
  }

  void genBloc({required List<String> opts, required bool exclude}) {
    BlocGenerator generator;
    Directory dir = Directory(modelDir);
    dir.list(recursive: false).forEach((f) {
      bool skip = opts.where((e) => f.path.endsWith(e)).isNotEmpty;
      if (!exclude) skip = !skip;
      if (skip) {
      } else {
        ReCase reCase = new ReCase(basenameWithoutExtension(f.path));
        String className = reCase.pascalCase;
        generator = BlocGenerator(this, className);
        var code = generator.generateDartClasses().code;
        File file = new File(blocDir + '/' + reCase.snakeCase + '.dart');
        file.writeAsString(code);
//      print("BlocProvider(create: (context) => "+reCase.pascalCase+"Bloc(),),\n");
//      print("Future<List<"+reCase.pascalCase+">> get" + reCase.pascalCase + "() async {}");
//      print("Future<List<"+reCase.pascalCase+">> " + reCase.camelCase +
//          "Delete("+reCase.pascalCase+" "+reCase.camelCase+") async {}");
      }
    });
//    print("add to API Client >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  }

  void genWidget({required List<String> opts, required bool exclude}) {
    WidgetGenerator generator;
    Directory dir = Directory(modelDir);
    dir.list(recursive: false).forEach((f) {
      bool skip = opts.where((e) => f.path.endsWith(e)).isNotEmpty;
      if (!exclude) skip = !skip;
      if (skip) {
      } else {
        ReCase reCase = new ReCase(basenameWithoutExtension(f.path));
        String className = reCase.pascalCase;
        generator = WidgetGenerator(this, appDir, className);
        new File(listDir + '/' + reCase.snakeCase + '_widget.dart')
            .writeAsString(
//      print(
                generator.generateDartClasses().code);
      }
    });
  }

  Future<void> intl() async {
//    File txt = File(appDir + "/intl.txt");
    Map<String, String> all = Map();
    Directory dir = Directory(jsonDir);
    await dir.list(recursive: false).forEach((f) {
      ReCase reCase = new ReCase(basenameWithoutExtension(f.path));
      String className = reCase.pascalCase;
      ModelGenerator modelGenerator = new ModelGenerator(className);

      final filePath = (join(jsonDir, reCase.originalText + '.json'));

      final jsonRawData = new File(filePath).readAsStringSync();

      dynamic x = json.decode(jsonRawData);
      if (x is List) {
        x.elementAt(0).keys.forEach((element) {
          if (all.containsKey(element) == false) {
            all.putIfAbsent(element, () => _recase(element));
          }
        });
      } else {
        x.keys.forEach((element) {
          if (all.containsKey(element) == false) {
            all.putIfAbsent(element, () => _recase(element));
          }
        });
      }
    });
    all.values.forEach((element) {
//      txt.writeAsStringSync(element);
      print(element);
    });

    ///sed "s/Ass /Asset /g; s/Cust /Customer /g; s/Pkg /Package /g; s/Drv /Driver /g; s/Sc /Service Center /g; s/Flt /Fleet /g; s/Dvc /Device /g; s/Egf /Exit Geo-fence /g; s/Rt //g; s/Adn //g; s/Atrac //g; s/At //g; s/Atype /Accident Type /g; s/Dw /Driver Reward /g; s/Eh //g; s/Fms //g; s/Frm /Fuelrod /g; s/Lv //g; s/Ot //g; s/Si //g; s/Sub /Subscription /g; s/To //g; s/Ts //g; s/Uacc //g; s/Uss //g; s/Usr //g; s/Vass //g; s/Vi //g; s/Vmd //g; s/Vty //g; " msg.txt/
    ///
//    all.keys.forEach((element) {
//      print('if(key == "'+element+'"){return S.of(context).' + ReCase(element).camelCase + ";}");
//    });
  }

  String _recase(s) {
    ReCase reCase = new ReCase(s);

    return ('"' + reCase.camelCase + '": "' + reCase.titleCase + '",');
  }

  Future<void> genClientCRUD() async {
    final formatter = new DartFormatter();
    Directory dir = Directory(jsonDir);
    await dir.list(recursive: false).forEach((f) {
      ReCase reCase = new ReCase(basenameWithoutExtension(f.path));

      String pascalCase = reCase.pascalCase;
      String camelCase = reCase.camelCase;
      String snakeCase = reCase.snakeCase;

      print(formatter.format("  Future<" +
          pascalCase +
          "> " +
          camelCase +
          "(int id) async {"
              "    Uresponse response = await get('/" +
          camelCase +
          "/' + id.toString());"
              "    return  " +
          pascalCase +
          ".fromJson(response.data);"
              "  }"
              ""
              "  Future<List<" +
          pascalCase +
          ">> " +
          camelCase +
          "List() async {"
              "    List<" +
          pascalCase +
          "> " +
          camelCase +
          "s = [];"
              "    Uresponse response = await post('/" +
          camelCase +
          "/list');"
              "    if(response.data is List) {"
              "      List<dynamic> list = response.data;"
              "      list.forEach((map) {"
              "        " +
          camelCase +
          "s.add(" +
          pascalCase +
          ".fromJson(map));"
              "      });"
              "    }"
              "    return " +
          camelCase +
          "s;"
              "  }"
              ""
              "  Future<void> " +
          camelCase +
          "Delete(" +
          pascalCase +
          " " +
          camelCase +
          ") async{"
              "    await delete('/" +
          camelCase +
          "/'+ " +
          camelCase +
          "." +
          camelCase +
          "Id.toString());"
              "  }"
              ""
              "  Future<" +
          pascalCase +
          "> " +
          camelCase +
          "Put(" +
          pascalCase +
          " " +
          camelCase +
          ") async {"
              "    Uresponse response = await put('/" +
          camelCase +
          "/'+" +
          camelCase +
          "." +
          camelCase +
          "Id.toString(),"
              "      data: " +
          camelCase +
          ".toJson(),"
              "    );"
              "    return " +
          pascalCase +
          ".fromJson(response.data);"
              "  }"
              ""
              "  Future<" +
          pascalCase +
          "> " +
          camelCase +
          "Create(" +
          pascalCase +
          " " +
          camelCase +
          ") async {"
              "    Uresponse response = await post('/" +
          camelCase +
          "',"
              "      data: " +
          camelCase +
          ".toJson(),"
              "    );"
              "    return " +
          pascalCase +
          ".fromJson(response.data);"
              "  }"));
    });
  }

  void getMenu() async {
/*
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'mysql.ti', port: 3306, user: 'root', db: 'ubiqtrac'));

    Results results = await conn
        .query('select * from vts_module_root a join vts_module b on b.mod_mr_id=a.mr_id order by MR_ORDER ');
    List<String> menus = [];
    for (Row row in results) {
      row.fields.forEach((key, value) {
        if(key == 'MR_NAME') {
          if(menus.contains(value.toString()) == false) {
            menus.add(value.toString());
          }
        }
      });
    }
    p("////////////////////MENU String////////////////////////////////");
    menus.forEach((m) {
      p("\"menu"+m.pascalCase.replaceAll('&', '')+"\" : \""+m.pascalCase+"\",");
    });
    p("////////////////////MENU String////////////////////////////////");
    p("////////////////////MENU ////////////////////////////////");
    menus.forEach((m) {
      p('new Menu(Icons.note,S.of(context).menu'+m.pascalCase+','+m.toString()+'Page()),');
    });
    p("////////////////////MENU ////////////////////////////////");
    menus.forEach((m) {
      p('mkdir '+m.snakeCase.replaceAll('&', ''));
      p('echo "import \'package:flutter/cupertino.dart\'; \n class '+m.pascalCase.replaceAll('&', '')+'Page extends StatelessWidget{  @override  Widget build(BuildContext context) {        throw UnimplementedError();  }}" > '+m.snakeCase.replaceAll('&', '')+'/'+m.snakeCase.replaceAll('&', '')+'_page.dart');
    });*/
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
                && line.contains('Bloc.of(context)')
            ) {
              res.add(line.substring(line.indexOf('(')+1, line.indexOf('.of')));
            }
          });
        }
      }
    });
    res.add('CommonOptionFormBloc');
    return res;
  }

  String importModel(List<String> blocs) {
    String code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += 'import \'package:rest_client/model/' + bloc.snakeCase + '.dart\';\n';
    });
    return code;
  }

  String importBloc(List<String> blocs) {
    String code = '';
    blocs.forEach((e) {
      ReCase bloc = ReCase(e.replaceAll('FormBloc', ''));
      code += 'import \'package:rest_client/bloc/' + bloc.snakeCase + '.dart\';\n';
    });
    return code;
  }
}

///Bloc Generator based on Json file.
// void main() {
// new Gen().genModel();
// new Gen().genBloc();
//  new Gen().genProvider();
//  new Gen().genWidget();
//  new Gen().intl();
//  new Gen().genClientCRUD();
//  new Gen().getMenu();
// }
