// @dart=2.9
import 'gen.dart';

void main(List<String> arguments) {
  Gen gen = Gen('../ubiqtrac_flutter/rest_client/lib/');

  gen.genBloc(opts: [
    '/user.dart',
    '/customer.dart',
    // 'request_parameter.dart',
    // 'uresponse.dart',
    // 'common_option.dart',
    // 'locator.dart',
    // 'media.dart'
  ], exclude: false);


  gen.genWidget(opts: [
    '/user.dart',
    '/customer.dart',
    // 'request_parameter.dart',
    // 'uresponse.dart',
    // 'common_option.dart',
    // 'locator.dart',
    // 'media.dart'
  ], exclude: false);

}
