import 'dart:io';

import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';

class AddLibraryForEachXsdFile implements GeneratorStage {
  final Directory xsdDirectory;
  AddLibraryForEachXsdFile(this.xsdDirectory);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    List<File> xsdFiles = xsdDirectory
        .listSync(recursive: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.xsd'))
        .toList();

    var libraries = <LibraryWithSource>[];

    for (var xsdFile in xsdFiles) {
      var library = generateFromFile(xsdFile);

      if (library != null) {
        libraries.add(library);
      }
    }
    return libraries;
  }
}

LibraryWithSource? generateFromFile(File xsdSourceFile) {
  try {
    var schema = Schema.fromFile(xsdSourceFile);

    return LibraryWithSource(xsdSourceFile: xsdSourceFile, schema: schema);
  } catch (e) {
    log.warning(
      'Error creating Dart code from: ${xsdSourceFile.path} Error: $e',
    );
    return null;
  }
}
