import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

class CheckIfLibraryMemberNamesAreUnique implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var library in libraries) {
      processLibrary(library);
    }
    return libraries;
  }

  void processLibrary(LibraryWithSource library) {
    var namesAndModels = findNamesAndModels(library);
    var allNames = namesAndModels.map((nameAndClasz) => nameAndClasz.name);
    var namesThatAreNotUnique = allNames
        .where((name) => allNames.where((n) => n == name).length > 1)
        .toSet();
    for (var noneUniqueName in namesThatAreNotUnique) {
      var nameAndModelsThatAreNotUnique = namesAndModels
          .where((nameAndClass) => nameAndClass.name == noneUniqueName)
          .toList();
      for (var nameAndModelThatIsNotUnique in nameAndModelsThatAreNotUnique) {
        for (var namePath in nameAndModelThatIsNotUnique.xsdNamePaths.values) {
          log.severe(
            "In CodeGenerator.nameMapping add: '${namePath.join('.')}' : 'YourUniqueName' ",
          );
        }
      }
    }
  }

  List<NameAndCodeModel> findNamesAndModels(LibraryWithSource library) => [
    ...createNameAndModel<Class>(
      library.classes,
      (clasz) => NameAndCodeModel(clasz.name.toString(), clasz),
    ),
    ...createNameAndModel<Enumeration>(
      library.enumerations,
      (enumeration) =>
          NameAndCodeModel(enumeration.name.toString(), enumeration),
    ),
    ...createNameAndModel<TypeDef>(
      library.typeDefs,
      (typeDef) => NameAndCodeModel(typeDef.alias.name, typeDef),
    ),
  ];

  Iterable<NameAndCodeModel> createNameAndModel<T extends CodeModel>(
    List<T>? codeModels,
    NameAndCodeModel Function(T) conversion,
  ) => (codeModels ?? <T>[]).map(conversion);
}

class NameAndCodeModel {
  final String name;
  final CodeModel codeModel;

  NameAndCodeModel(this.name, this.codeModel);

  late final Map<XmlElement, List<String>> xsdNamePaths = findXsdNamePaths();

  Map<XmlElement, List<String>> findXsdNamePaths() {
    var xsdNamePaths = <XmlElement, List<String>>{};
    for (var xsdSource
        in (codeModel as HasMappedXsdElements).mappedXsdElements) {
      var xsdNamerPath = findXsdNamePath(xsdSource);
      xsdNamePaths[xsdSource] = xsdNamerPath;
    }
    return xsdNamePaths;
  }
}

abstract interface class HasMappedXsdElements {
  /// XSD elements that where the source of a CodeModel
  List<XmlElement> get mappedXsdElements;
}
