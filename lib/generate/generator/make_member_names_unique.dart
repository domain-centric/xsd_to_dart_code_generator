import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

class MakeMemberNamesUnique implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var library in libraries) {
      processLibrary(library);
    }
    return libraries;
  }

  void processLibrary(LibraryWithSource library) {
    var namesAndClasses = findNamesAndClasses(library);
    var allNames = namesAndClasses.map((nameAndClasz) => nameAndClasz.name);
    var namesThatAreNotUnique = allNames
        .where((name) => allNames.where((n) => n == name).length > 1)
        .toSet();
    for (var noneUniqueName in namesThatAreNotUnique) {
      var found = namesAndClasses
          .where((nameAndClass) => nameAndClass.name == noneUniqueName)
          .toList();
      for (var f in found) {
        print('> ${f.name}-${f.xsdNamePaths.values}');
      }
    }
    if (namesThatAreNotUnique.isNotEmpty) {
      //FIXME implement making names longer when needed
      log.warning(namesThatAreNotUnique.join(', '));
    }
  }

  Iterable<NameAndClass> findNamesAndClasses(LibraryWithSource library) =>
      (library.classes ?? []).cast<ClassToBePostProcessed>().map(
        (clasz) => NameAndClass(clasz.name.toString(), clasz),
      );
}

class NameAndClass {
  final String name;
  final ClassToBePostProcessed clasz;

  NameAndClass(this.name, this.clasz);

  late final Map<XmlElement, List<String>> xsdNamePaths = findXsdNamePaths();

  Map<XmlElement, List<String>> findXsdNamePaths() {
    var xsdNamePaths = <XmlElement, List<String>>{};
    for (var xsdSource in clasz.xsdSources) {
      var xsdNamerPath = findXsdNamePath(xsdSource);
      xsdNamePaths[xsdSource] = xsdNamerPath;
    }
    return xsdNamePaths;
  }

  List<String> findXsdNamePath(
    XmlElement element, [
    List<String>? foundXsdNames,
  ]) {
    foundXsdNames = foundXsdNames ?? [];
    var nameAttribute = element.getAttribute('name');
    if (nameAttribute != null) {
      foundXsdNames.insert(0, nameAttribute);
    }
    if (element.parentElement == null) {
      return foundXsdNames;
    }
    var parent = element.parentElement!;
    return findXsdNamePath(parent, foundXsdNames);
  }
}
