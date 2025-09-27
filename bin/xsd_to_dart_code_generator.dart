import 'dart:io';
import 'package:xsd_to_dart_code_generator/generate/generate_from_directory.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

void main(List<String> arguments) {
  initLog();
  generateDartCode(
    Directory('xsd'),
    DefaultOutputPathConverter(
      fileNameMappings: {
        'IEC61131_10_Ed1_0_Spc1_0': 'spc',
        'IEC61131_10_Ed1_0_SmcExt1_0_Spc1_0': 'smcext',
      },
    ),
  );
  exit(0);
}
