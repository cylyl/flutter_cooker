// @dart=2.9
import 'dart:convert';
import 'dart:io';

import 'gen.dart';

Future<void> main(List<String> arguments) async {

  var proj_dir = 'ubiqtrac_flutter_gen';


  // bool exclude = true;
  bool exclude = false;
  List<String> excludeModels = [
    'request_parameter.dart',
    'uresponse.dart',
    'common_option.dart',
    'locator.dart',
    'media.dart'
  ];
  List<String> models = [];

  Stream<List<int>>  stream = File('../'+proj_dir+'/the_hunter_app/lib/bloc_config.dart')
      .openRead();
  await stream.transform(utf8.decoder)
      .transform(new LineSplitter())
      .forEach((line) {
        if(line.startsWith("//GEN ")) {
          models.add(line.replaceAll("//GEN ", '') + '.dart');
        }
  });

  if(exclude) {
    models.addAll(excludeModels);
  }

  Gen gen = Gen('../'+proj_dir+'/rest_client/lib/');

  gen.genBloc(opts: models, exclude: exclude);
  gen.genWidget(opts: models, exclude: exclude);

}
