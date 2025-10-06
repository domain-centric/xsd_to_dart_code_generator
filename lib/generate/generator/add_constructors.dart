import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

class AddConstructors implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var newLibraries = <LibraryWithSource>[];
    for (var library in libraries) {
      var newClasses = generateClassesWithConstructors(libraries, library);
      var newLibrary = library.copyWith(classes: newClasses);
      newLibraries.add(newLibrary);
    }
    return newLibraries;
  }

  List<ClassFromXsd> generateClassesWithConstructors(
    List<LibraryWithSource> libraries,
    LibraryWithSource library,
  ) {
    var newClasses = <ClassFromXsd>[];
    for (var clasz in library.classes ?? []) {
      if (clasz.modifier == ClassModifier.abstract_interface) {
        // add as is
        newClasses.add(clasz);
      } else {
        /// add with constructor
        var newClass = generateClassWithConstructor(libraries, clasz);
        newClasses.add(newClass);
      }
    }
    return newClasses;
  }

  ClassFromXsd generateClassWithConstructor(
    List<LibraryWithSource> libraries,
    ClassFromXsd clasz,
  ) {
    //TODO remove?
    // if (clasz.abstract != null && clasz.abstract == true) {
    //   // all generated abstract classes are interfaces and have no constructor
    //   return clasz;
    // }
    var constructor = createConstructor(libraries, clasz);
    return clasz.copyWith(constructors: [constructor]);
  }

  List<ClassFromXsd> findSuperClasses(
    ClassFromXsd clasz,
    List<LibraryWithSource> libraries,
  ) {
    if (clasz.superClass == null) {
      return [];
    }
    var superClass = findClass(
      clasz.superClass! as XsdReferenceType,
      libraries,
    );
    return findSuperClassesRecursively([superClass], libraries);
  }

  List<ClassFromXsd> findSuperClassesRecursively(
    List<ClassFromXsd> foundSuperClasses,
    List<LibraryWithSource> libraries,
  ) {
    var last = foundSuperClasses.last;
    if (last.superClass == null) {
      return foundSuperClasses;
    }
    var superClass = findClass(last.superClass! as XsdReferenceType, libraries);
    foundSuperClasses.add(superClass);
    return findSuperClassesRecursively(foundSuperClasses, libraries);
  }

  ClassFromXsd findClass(
    XsdReferenceType classToFind,
    List<LibraryWithSource> libraries,
  ) {
    var nameSpaceUri = classToFind.xsdNamespaceUri;
    var library = findLibrary(libraries, nameSpaceUri);
    var foundClass = (library.classes ?? []).firstWhereOrNull(
      (c) => c.name.toString() == classToFind.name,
    );
    if (foundClass == null) {
      log.warning('Could not find class: ${classToFind.name}');
      return library.classes?.first
          as ClassFromXsd; //FIXME remove this temporary fix
    }
    return foundClass as ClassFromXsd;
  }

  LibraryWithSource findLibrary(
    List<LibraryWithSource> libraries,
    String nameSpaceUri,
  ) => libraries.firstWhere((l) => l.schema.targetNameSpaceUri == nameSpaceUri);

  Constructor createConstructor(
    List<LibraryWithSource> libraries,
    ClassFromXsd clasz,
  ) {
    var constructParameters = createConstructorParameters(clasz, libraries);
    return Constructor(
      Type(clasz.name.toString()),
      parameters: constructParameters,
    );
  }

  ConstructorParameters createConstructorParameters(
    ClassFromXsd clasz,
    List<LibraryWithSource> libraries,
  ) {
    var localFields = clasz.fields ?? [];
    var superClasses = findSuperClasses(clasz, libraries);
    var superFields = superClasses
        .map((c) => c.fields ?? [])
        .expand((e) => e)
        .toList();
    var constructParameters = ConstructorParameters([
      for (var superField in superFields)
        ConstructorParameter.named(
          superField.name,
          type: superField.type,
          qualifier: Qualifier.super$,
          required: isRequired(superField),
        ),
      for (var localField in localFields)
        ConstructorParameter.named(
          localField.name,
          type: localField.type,
          qualifier: Qualifier.this$,
          required: isRequired(localField),
        ),
    ]);
    return constructParameters;
  }

  bool isRequired(Field field) =>
      (field.type is Type) ? !(field.type as Type).nullable : false;
}
