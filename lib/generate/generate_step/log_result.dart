import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generate_step/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

class LogResult implements GeneratorStep {
  final OutputPathConverter outputPathConverter;

  LogResult(this.outputPathConverter);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var library in libraries) {
      var dartFile = outputPathConverter.convertToDartFile(
        library.xsdSourceFile,
      );
      log.info('=================================');
      log.info(dartFile.path);
      log.info("\n${library.toFormattedString()}");
    }
    return libraries;
  }
}
