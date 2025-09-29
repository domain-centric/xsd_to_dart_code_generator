import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_simple_type_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

// If element name is other than the name of its type and type is complex type create a new class that extends the type
// e.g.       <xsd:element name="NamespaceDecl" type="ppx:NamespaceDecl"/> // creates nothing
//                           <xsd:element name="DataTypeDecl" type="ppx:UserDefinedTypeDecl"/> // creates a class DataTypeDecl that extends UserDefinedTypeDecl

class AddMappedTypes implements GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var processedLibraries = <LibraryWithSource>[];
    for (var library in libraries) {
      var classes = library.classes ?? [];
      var newClasses = <ClassToBePostProcessed>{};
      for (var clasz in classes) {
        var fields = clasz.fields ?? [];
        for (var field in fields) {
          if (isChoiceField(field)) {
            var mappedClasses = createChoiceMappedClasses(
              library.schema,
              field,
            );
            newClasses.addAll(mappedClasses);
            continue;
          }
          var element = findElement(field);
          if (element != null && isMapped(element)) {
            var mappedClass = createMappedClass(library.schema, element);
            newClasses.add(mappedClass);
          }
        }
      }
      print(newClasses.map((c) => c.name).join(', '));

      classes.addAll(newClasses);

      var newLibrary = library.copyWith(classes: classes);
      processedLibraries.add(newLibrary);
    }
    return processedLibraries;
  }

  bool isMapped(XmlElement xsdElement) {
    var nameValue = xsdElement.getAttribute('name');
    var typeValue = xsdElement.getAttribute('type');
    if (nameValue == null || typeValue == null) {
      return false;
    }
    var typeName = typeValue.split(':').last;
    if (isSimpleType(typeName)) {
      return false;
    }
    if (nameValue == 'DataTypeDecl') {
      print('!!!');
    }
    var found = nameValue != typeName;
    return found;
  }

  bool isSimpleType(String typeName) =>
      convertXsdTypeToDartType(typeName, isNullable: false) != null;

  ClassToBePostProcessed createMappedClass(
    Schema schema,
    XmlElement xsdElement,
  ) {
    var className = toValidDartNameStartingWitUpperCase(
      xsdElement.getAttribute('name'),
    );
    var superClass = XsdReferenceType.fromXsdElement(schema, xsdElement);
    return ClassToBePostProcessed(
      className,
      xsdSource: xsdElement,
      superClass: superClass,
    );
  }

  bool isChoiceField(Field field) => field.type is XsdChoiceType;

  List<ClassToBePostProcessed> createChoiceMappedClasses(
    Schema schema,
    Field field,
  ) {
    var classes = <ClassToBePostProcessed>[];
    var choice = field.type as XsdChoiceType;
    var elements = choice.elementsThatImplementThisType;
    for (var element in elements) {
      if (isMapped(element)) {
        classes.add(createMappedClass(schema, element));
      }
    }
    return classes;
  }

  XmlElement? findElement(Field field) {
    if (field is XsdElementField) {
      return field.xsdElement;
    }
    if (field is XsdAttributeField) {
      return field.xsdAttribute;
    }
    return null;
  }
}
