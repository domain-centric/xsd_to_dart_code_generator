import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_choice_interfaces.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_classes_from_complex_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_classes_from_simple_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_library_for_each_xsd_file.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_classes_for_mapped_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/log_result.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/make_member_names_unique.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

abstract class GeneratorStage {
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries);
}

class CodeGenerator extends DelegatingList<GeneratorStage>
    implements GeneratorStage {
  CodeGenerator.custom(super.generatorStages);

  CodeGenerator(Directory xsdDirectory, OutputPathConverter outputPathConverter)
    : super([
        AddLibraryForEachXsdFile(xsdDirectory),
        AddClassesFromComplexTypes(),
        AddClassesFromSimpleTypes(),
        AddClassesForMappedTypes(),
        AddChoiceInterfaces(),
        MakeMemberNamesUnique(),

        //TODO AddConstructors
        //TODO AddXmlConverterLibraties
        LogResult(outputPathConverter),
        // WriteResultToFile(outputPathConverter),
      ]);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var generatorStage in this) {
      libraries = generatorStage.generate(libraries);
    }
    return libraries;
  }
}
