import 'dart:io';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

void main(List<String> arguments) {
  initLog();
  var libraries = <LibraryWithSource>[];
  var xsdDirectory = Directory('xsd');
  var outputPathConverter = DefaultOutputPathConverter(
    fileNameMappings: {
      'IEC61131_10_Ed1_0_Spc1_0': 'spc',
      'IEC61131_10_Ed1_0_SmcExt1_0_Spc1_0': 'sysmac_extension',
    },
  );
  libraries = CodeGenerator(
    xsdDirectory,
    outputPathConverter,
  ).generate(libraries);

  exit(0);
}
