import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_choice_interfaces.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_classes_from_complex_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_types_from_simple_types.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_constructors.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_library_for_each_xsd_file.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/add_classes_for_mapped_elements.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/log_result.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/check_unique_names.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/merge_equal_classes.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/write_result_to_file.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';
import 'package:xsd_to_dart_code_generator/output_path_converter.dart';

abstract class GeneratorStage {
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries);
}

class CodeGenerator extends DelegatingList<GeneratorStage>
    implements GeneratorStage {
  CodeGenerator.custom(super.generatorStages);

  CodeGenerator({
    required Directory xsdDirectory,
    required OutputPathConverter outputPathConverter,
    XsdNamePathToTypeNameMapping nameMapping = const {},
  }) : super([
         AddLibraryForEachXsdFile(xsdDirectory),
         AddClassesFromComplexTypes(nameMapping),
         AddTypesFromSimpleTypes(nameMapping),
         AddClassesForMappedElements(),
         AddChoiceInterfaces(),
         MergeEqualClasses(),
         CheckIfLibraryMemberNamesAreUnique(),
         AddConstructors(),

         //TODO AddXmlConverterLibraries
         //LogResult(outputPathConverter),
         WriteResultToFile(outputPathConverter),
       ]);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var generatorStage in this) {
      libraries = generatorStage.generate(libraries);
    }
    return libraries;
  }
}
