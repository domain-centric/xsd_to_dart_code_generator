import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generate_step/add_choice_interfaces.dart';
import 'package:xsd_to_dart_code_generator/generate/generate_step/add_library_for_each_xsd_file.dart';
import 'package:xsd_to_dart_code_generator/generate/generate_step/add_mapped_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generate_step/log_result.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

abstract class GeneratorStep {
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries);
}

class CodeGenerator extends DelegatingList<GeneratorStep>
    implements GeneratorStep {
  CodeGenerator(Directory xsdDirectory, OutputPathConverter outputPathConverter)
    : super([
        AddLibraryForEachXsdFile(xsdDirectory),
        //TODO AddClassesFromComplexTypes
        //TODO AddClassesFromSimpleTypes
        AddChoiceInterfaces(),
        AddMappedTypes(),

        //TODO AddConstructors
        //TODO AddXmlConverterLibraties
        LogResult(outputPathConverter),
        // WriteResultToFile(outputPathConverter),
      ]);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var postProcessor in this) {
      libraries = postProcessor.generate(libraries);
    }
    return libraries;
  }
}
