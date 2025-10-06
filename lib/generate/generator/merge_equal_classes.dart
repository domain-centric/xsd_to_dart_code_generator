import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';

class MergeEqualClasses implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var newLibraries = <LibraryWithSource>[];
    for (var library in libraries) {
      var classes = (library.classes ?? []).cast<ClassToBePostProcessed>();
      var uniqueClasses = mergeEqualClasses(classes);
      var newLibrary = library.copyWith(classes: uniqueClasses);
      newLibraries.add(newLibrary);
    }
    return newLibraries;
  }

  List<ClassToBePostProcessed> mergeEqualClasses(
    List<ClassToBePostProcessed> classes,
  ) {
    Map<String, ClassToBePostProcessed> codeAndClassModels = {};

    for (var clasz in classes) {
      var code = clasz.toString();
      if (codeAndClassModels.keys.contains(code)) {
        var newClass = mergeClasses(codeAndClassModels, code, clasz);
        codeAndClassModels[code] = newClass;
      } else {
        codeAndClassModels[code] = clasz;
      }
    }
    return codeAndClassModels.values.toList();
  }

  ClassToBePostProcessed mergeClasses(
    Map<String, ClassToBePostProcessed> codeAndClassModels,
    String code,
    ClassToBePostProcessed clasz,
  ) {
    var classModel = codeAndClassModels[code]!;
    var xsdSources = classModel.xsdSources;
    xsdSources.addAll(clasz.xsdSources);
    var newClassModel = classModel.copyWith(xsdSources: xsdSources);
    return newClassModel;
  }
}
