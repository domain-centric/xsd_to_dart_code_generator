import 'dart:io';

import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/post_process/post_process.dart';

///TODO post procesing of libraries like:  implementing interfaces,  creating constructors, creating toXml methods, creating fromXml methods,

class AddChoiceInterfaces implements PostProcessor {
  @override
  Map<File, Library2> process(Map<File, Library2> libraries) {
    Map<File, Library2> processedLibraries = {};
    for (var libraryEntry in libraries.entries) {
      var newLibrary = libraryEntry.value;
      var classes = newLibrary.classes ?? [];
      var xsdChoiceTypes = findXsdChoiceTypes(classes);

      for (var xsdChoiceType in xsdChoiceTypes) {
        var interface = createInterface(xsdChoiceType);
        classes.add(interface);
        letClassesImplementIfNeeded(classes, xsdChoiceType);
      }

      newLibrary.copyWith(classes: classes);
      processedLibraries[libraryEntry.key] = newLibrary;
    }
    return processedLibraries;
  }

  Class createInterface(XsdChoiceType xsdChoiceType) {
    var owners = xsdChoiceType.elementsThatImplementThisType.map(
      (c) => c.getAttribute('name'),
    );
    var interface = Class(
      xsdChoiceType.name,
      abstract: true,
      docComments: [
        DocComment.fromString('Common interface for: ${owners.join(', ')}'),
      ],
    );
    return interface;
  }

  List<XsdChoiceType> findXsdChoiceTypes(List<Class> classes) {
    var xsdChoiceTypes = <XsdChoiceType>[];
    for (var clasz in classes) {
      var fields = (clasz.fields ?? []);
      var foundTypes = fields
          .map((f) => findAllTypes(f.type))
          .expand((l) => l)
          .whereType<XsdChoiceType>();
      xsdChoiceTypes.addAll(foundTypes);
    }
    return xsdChoiceTypes;
  }
}

void letClassesImplementIfNeeded(
  List<Class> classes,
  XsdChoiceType xsdChoiceType,
) {
  for (var clasz in classes) {
    if (isClassThatNeedsToImplement(clasz, xsdChoiceType)) {
      classes.remove(clasz);
      var classThatImplements = letClassImplement(clasz, xsdChoiceType);
      classes.add(classThatImplements);
    }
  }
}

ClassToBePostProcessed letClassImplement(
  Class clasz,
  XsdChoiceType xsdChoiceType,
) => (clasz as ClassToBePostProcessed).copyWith(
  implements: [
    if (clasz.implements != null) ...clasz.implements!,
    xsdChoiceType,
  ],
);

bool isClassThatNeedsToImplement(Class clasz, XsdChoiceType xsdChoiceType) =>
    (clasz is ClassToBePostProcessed) &&
    xsdChoiceType.elementsThatImplementThisType.contains(clasz.xsdSource);

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
