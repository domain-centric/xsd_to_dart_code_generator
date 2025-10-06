import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_class.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/field_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

class AddClassesFromComplexTypes extends GeneratorStage {
  final XsdNamePathToTypeNameMapping nameMapping;

  AddClassesFromComplexTypes(this.nameMapping);

  /// Converts xsd:complexType elements from the libraries XmlSchema to Dart classes
  /// Strategy:
  ///
  /// | XSD Construct             | Dart Equivalent                           |
  /// |---------------------------|-------------------------------------------|
  /// | `xsd:complexType`         | Dart class                                |
  /// | `xsd:element`             | Dart field                                |
  /// | `xsd:attribute`           | Dart field                                |
  /// | `xsd:sequence`            | Ordered fields                            |
  /// | `minOccurs="0"`           | Optional field (nullable)                 |
  /// | `maxOccurs="unbounded"`   | `List<T>`                                 |
  /// | `xsd:extension`           | Dart class inheritance (`extends`)        |
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    var newLibraries = <LibraryWithSource>[];
    for (var library in libraries) {
      List<ClassFromXsd> newClasses = generateClassesFromComplexTypes(library);
      var newLibrary = library.copyWith(classes: newClasses);
      newLibraries.add(newLibrary);
    }
    return newLibraries;
  }

  List<ClassFromXsd> generateClassesFromComplexTypes(
    LibraryWithSource library,
  ) {
    var schema = library.schema;
    final complexTypes = schema.findAllElements(
      'complexType',
      namespace: xsdNamespaceUri,
    );

    final newClasses = <ClassFromXsd>[];

    for (final complexType in complexTypes) {
      var newClass = generateClassFromComplexType(
        schema,
        complexType,
        nameMapping,
      );
      if (newClass != null) {
        newClasses.add(newClass);
      }
    }
    return newClasses;
  }
}

ClassFromXsd? generateClassFromComplexType(
  Schema schema,
  XmlElement complexType,
  XsdNamePathToTypeNameMapping nameMapping,
) {
  String typeName;
  try {
    typeName = findTypeName(complexType, nameMapping);
  } catch (e) {
    log.warning(
      'Could not find a valid Dart type name. Error: $e For: $complexType',
    );
    return null;
  }

  // var schema = findSchemaElement(complexType);

  var superClass = findSuperClass(schema: schema, complexType: complexType);

  List<Field> fields = generateFieldsFromXsdElement(
    schema: schema,
    nameMapping: nameMapping,
    typeName: typeName,
    complexType: complexType,
  );

  return ClassFromXsd(
    typeName,
    mappedXsdElements: [complexType],
    modifier: _classModifier(complexType),
    fields: fields,
    superClass: superClass,
  );
}

ClassModifier? _classModifier(XmlElement complexType) =>
    complexType.getAttribute('abstract') == 'true'
    ? ClassModifier.abstract
    : null;

Type? findSuperClass({
  required Schema schema,
  required XmlElement complexType,
}) {
  var complexContent = complexType
      .findElements('complexContent', namespace: xsdNamespaceUri)
      .firstOrNull;
  if (complexContent == null) return null;
  var extension = complexContent
      .findElements('extension', namespace: xsdNamespaceUri)
      .firstOrNull;
  if (extension == null) return null;
  var base = extension.getAttribute('base');
  if (base == null || base.isEmpty) return null;
  var namespaceUri = findTypeNamespaceUri(schema, base);
  var typeName = base.split(':').last;
  if (namespaceUri != null) {
    return XsdReferenceType(
      typeName,
      xsdElement: complexType,
      xsdNamespaceUri: namespaceUri,
    );
  }
  return Type(typeName);
}

String? findTypeNamespaceUri(Schema schema, String base) {
  var baseValues = base.split(':');
  var nameSpacePrefix = baseValues.length == 2 ? baseValues.first : null;
  if (nameSpacePrefix != null) {
    return schema.findNameSpaceUri(nameSpacePrefix);
  }
  return null;
}

///FIXME: xsd:group!!!!
