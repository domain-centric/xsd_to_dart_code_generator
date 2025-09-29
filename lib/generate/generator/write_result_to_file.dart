import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

class WriteResultToFile implements GeneratorStage {
  final OutputPathConverter outputPathConverter;

  WriteResultToFile(this.outputPathConverter);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var library in libraries) {
      var dartFile = outputPathConverter.convertToDartFile(
        library.xsdSourceFile,
      );

      dartFile.createSync(recursive: true);
      dartFile.writeAsStringSync(library.toFormattedString());
    }
    return libraries;
  }
}
