import 'dart:io';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_file.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/generate/post_process/post_process.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

void generateDartCode(
  Directory xsdFileDirectory,
  OutputPathConverter outputPathConverter,
) {
  StringBuffer();
  final List<File> xsdFiles =
      Directory("./xsd") // TODO get from xsdFileDirectory
          .listSync(recursive: false)
          .where((element) => element.path.endsWith(".xsd"))
          .map((e) => File(e.path))
          .toList();

  var libraries = <LibraryWithSource>[];

  for (var xsdFile in xsdFiles) {
    var library = generateFromFile(xsdFile);

    if (library != null) {
      libraries.add(library);
    }
  }

  libraries = PostProcessors().generateOrImprove(libraries);

  for (var library in libraries) {
    var dartFile = outputPathConverter.convertToDartFile(library.xsdSourceFile);
    log.info('=================================');
    log.info(dartFile.path);
    log.info("\n${library.toFormattedString()}");
    dartFile.createSync(recursive: true);
    dartFile.writeAsStringSync(library.toFormattedString());
  }
}
