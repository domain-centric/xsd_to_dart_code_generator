import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

class AddChoiceInterfaces implements GeneratorStage {
  final XsdNamePathToTypeNameMapping nameMapping;

  AddChoiceInterfaces(this.nameMapping);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var processedLibraries = <LibraryWithSource>[];

    for (var library in libraries) {
      var classes = (library.classes ?? []).cast<ClassFromXsd>();
      var xsdChoiceTypes = findXsdChoiceTypes(classes);

      var newClasses = <ClassFromXsd>[];
      newClasses.addAll(
        xsdChoiceTypes
            .map((xsdChoiceType) => InterfaceFromXsdChoice(xsdChoiceType))
            .toList(),
      );
      for (var clasz in classes) {
        var toImplement = findTypesToImplement(clasz, xsdChoiceTypes);
        if (toImplement.isEmpty) {
          newClasses.add(clasz);
        } else {
          newClasses.add(letClassImplement(clasz, toImplement));
        }
      }
      var newLibrary = library.copyWith(classes: newClasses);
      processedLibraries.add(newLibrary);
    }
    return processedLibraries;
  }

  List<TypeFromXsdChoice> findXsdChoiceTypes(List<Class> classes) {
    var xsdChoiceTypes = <TypeFromXsdChoice>[];
    for (var clasz in classes) {
      if (clasz is InterfaceFromXsdChoice) {
        xsdChoiceTypes.add(clasz.typeFromXsdChoice);
      } else {
        var fields = (clasz.fields ?? []);
        var foundTypes = fields
            .map((f) => findAllTypes(f.type))
            .expand((l) => l)
            .whereType<TypeFromXsdChoice>();
        xsdChoiceTypes.addAll(foundTypes);
      }
    }
    return xsdChoiceTypes;
  }

  List<TypeFromXsdChoice> findTypesToImplement(
    Class clasz,
    List<TypeFromXsdChoice> xsdChoiceTypes,
  ) {
    var className = clasz.name.toString();
    var implementedNames = (clasz.implements ?? []).map((type) => type.name);
    var typesToImplement = <TypeFromXsdChoice>[];
    for (var xsdChoiceType in xsdChoiceTypes) {
      var classNamesToFind = xsdChoiceType.elementsThatImplementThisType.map(
        (e) => findTypeName(e, nameMapping),
      );
      if (!implementedNames.contains(xsdChoiceType.name) &&
          classNamesToFind.contains(className)) {
        typesToImplement.add(xsdChoiceType);
      }
    }
    return typesToImplement;
  }

  ClassFromXsd letClassImplement(
    Class clasz,
    List<TypeFromXsdChoice> toImplement,
  ) => (clasz as ClassFromXsd).copyWith(
    implements: [
      if (clasz.implements != null) ...clasz.implements!,
      ...toImplement,
    ],
  );

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
}
