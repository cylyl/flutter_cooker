import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'gen.dart';

Future<void> main(List<String> args) async {
  // Check if the correct number of arguments is provided
  if (args.length < 3) {
    print('Error: Invalid number of arguments.' + args.length.toString());
    print('Usage: dart flutter_cooker.dart <model,bloc,provider,widget,intl,crud,menu>  <config_file> <output_dir> <exclude file>');
    print('Usage: dart flutter_cooker.dart  config.dart out_dir "a.dart,b.dart"');
    exit(1);
  }

  // Extract the arguments
  final mode = args[0];
  final configFile = args[1];
  final outputDir = args[2];

  // Verify that the config file exists
  if (!File(configFile).existsSync()) {
    print('Error: Config file not found.');
    exit(1);
  }

  // Verify that the output directory exists
  if (!Directory(outputDir).existsSync()) {
    print('Error: Output directory not found.');
    exit(1);
  }

  // Perform your desired operations with the provided arguments
  print('Config File: $configFile');
  print('Output Directory: $outputDir');

  if(args.length == 4) {
    print('Exclude File: ${args[3]}');
  }

  List<String> excludeModels = args.length == 2 ? args[3].split(',') : [];


  List<String> models = [];

  var stream = File(configFile).openRead();
  await stream
      .transform(utf8.decoder)
      .transform(new LineSplitter())
      .forEach((line) {
    if (line.startsWith("//GEN ")) {
      models.add(line.replaceAll("//GEN ", '') + '.dart');
    }
  });

  Gen gen = Gen(outputDir);

  print('Mode: $mode');

  switch(mode) {
    case 'model':
      gen.genModel();
      break;
    case 'bloc':
      gen.genBloc(excludes: excludeModels);
      break;
    case 'provider':
      gen.genProvider();
      break;
    case 'widget':
      gen.genWidget(excludes: excludeModels);
      break;
    case 'intl':
      gen.intl();
      break;
    case 'crud':
      gen.genClientCRUD();
      break;
    case 'menu':
      gen.getMenu();
      break;
  }
}
