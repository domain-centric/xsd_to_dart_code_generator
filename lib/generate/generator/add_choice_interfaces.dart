import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';

class AddChoiceInterfaces implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var processedLibraries = <LibraryWithSource>[];
    for (var library in libraries) {
      var classes = library.classes ?? [];
      var xsdChoiceTypes = findXsdChoiceTypes(classes);

      for (var xsdChoiceType in xsdChoiceTypes) {
        var interface = createInterface(xsdChoiceType);
        classes.add(interface);
        letClassesImplementIfNeeded(classes, xsdChoiceType);
      }

      var newLibrary = library.copyWith(classes: classes);
      processedLibraries.add(newLibrary);
    }
    return processedLibraries;
  }

  ClassFromXsd createInterface(TypeFromXsdChoice xsdChoiceType) {
    var owners = xsdChoiceType.elementsThatImplementThisType.map(
      (c) => c.getAttribute('name'),
    );
    var interface = ClassFromXsd(
      xsdChoiceType.name,
      mappedXsdElements: [xsdChoiceType.xsdSource],
      modifier: ClassModifier.abstract_interface,
      docComments: [
        DocComment.fromString('Common interface for: ${owners.join(', ')}'),
      ],
    );
    return interface;
  }

  List<TypeFromXsdChoice> findXsdChoiceTypes(List<Class> classes) {
    var xsdChoiceTypes = <TypeFromXsdChoice>[];
    for (var clasz in classes) {
      var fields = (clasz.fields ?? []);
      var foundTypes = fields
          .map((f) => findAllTypes(f.type))
          .expand((l) => l)
          .whereType<TypeFromXsdChoice>();
      xsdChoiceTypes.addAll(foundTypes);
    }
    return xsdChoiceTypes;
  }
}

void letClassesImplementIfNeeded(
  List<Class> classes,
  TypeFromXsdChoice xsdChoiceType,
) {
  for (var clasz in classes) {
    if (isClassThatNeedsToImplement(clasz, xsdChoiceType)) {
      classes.remove(clasz);
      var classThatImplements = letClassImplement(clasz, xsdChoiceType);
      classes.add(classThatImplements);
    }
  }
}

ClassFromXsd letClassImplement(Class clasz, TypeFromXsdChoice xsdChoiceType) =>
    (clasz as ClassFromXsd).copyWith(
      implements: [
        if (clasz.implements != null) ...clasz.implements!,
        xsdChoiceType,
      ],
    );

bool isClassThatNeedsToImplement(Class clasz, TypeFromXsdChoice xsdChoiceType) {
  var classImplements = (clasz.implements ?? []).map((type) => type.name);
  if (classImplements.contains(xsdChoiceType.name)) {
    // already implemented
    return false;
  }
  var className = clasz.name.toString();
  var namesToFind = xsdChoiceType.elementsThatImplementThisType.map(
    (e) => e.getAttribute('name'),
  );
  var needsToImplement = namesToFind.contains(className);
  return needsToImplement;
}

List<BaseType> findAllTypes(BaseType? type) {
  if (type == null) {
    return [];
  }
  var types = <BaseType>[type];

  if (type is Type) {
    for (var generic in type.generics) {
      types.addAll(findAllTypes(generic));
    }
  }
  return types;
}
