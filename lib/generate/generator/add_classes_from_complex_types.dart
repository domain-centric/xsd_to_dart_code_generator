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
      var schema = library.schema;
      final complexTypes = schema.findAllElements(
        'complexType',
        namespace: xsdNamespaceUri,
      );

      final newClasses = <ClassToBePostProcessed>[];

      for (final complexType in complexTypes) {
        var newClass = generateFromComplexType(schema, complexType);
        if (newClass != null) {
          newClasses.add(newClass);
        }
      }

      newLibraries.add(library.copyWith(classes: newClasses));
    }
    return newLibraries;
  }
}

ClassToBePostProcessed? generateFromComplexType(
  Schema schema,
  XmlElement complexType,
) {
  String typeName;
  try {
    typeName = findTypeName(complexType);
  } catch (e) {
    log.warning(
      'Could not find a valid Dart type name. Error: $e For: $complexType',
    );
    return null;
  }

  // var schema = findSchemaElement(complexType);

  var superClass = findSuperClass(schema: schema, complexType: complexType);

  var isAbstract = _isAbstract(complexType);

  List<Field> fields = generateFieldsFromXsdElement(
    schema: schema,
    typeName: typeName,
    complexType: complexType,
  );

  return ClassToBePostProcessed(
    typeName,
    xsdSource: complexType,
    abstract: isAbstract,
    fields: fields,
    superClass: superClass,
  );
}

bool _isAbstract(XmlElement complexType) =>
    complexType.getAttribute('abstract') == 'true';

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
    return TypeWithXsdNameSpaceUri(typeName, xsdNamespaceUri: namespaceUri);
  }
  return Type(typeName);
}

/// TODO Needs to lookup the proper [libraryUri] based on the [xsdNamespaceUri] when PostProcessing
class TypeWithXsdNameSpaceUri extends Type {
  final String xsdNamespaceUri;
  TypeWithXsdNameSpaceUri(
    super.name, {
    super.nullable = false,
    required this.xsdNamespaceUri,
  });
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
