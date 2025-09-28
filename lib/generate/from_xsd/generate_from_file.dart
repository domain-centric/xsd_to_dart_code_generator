import 'dart:io';

import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_enum.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_name.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_typedef.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_complex_type.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_simple_type.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

/// Converts a xsd file to a Library (from the dart_code package)
/// Strategy:
///
/// | XSD Construct             | Dart Equivalent                           |
/// |---------------------------|-------------------------------------------|
/// | `xsd:complexType`         | Dart class                                |
/// | `xsd:element`             | Dart field                                |
/// | `xsd:attribute`           | Dart field                                |
/// | `xsd:sequence`            | Ordered fields                            |
/// | `xsd:choice`              | One of several fields (can be polymorphic)|
/// | `xsd:group`               | Dart class or reused field group          |
/// | `minOccurs="0"`           | Optional field (nullable)                 |
/// | `maxOccurs="unbounded"`   | `List<T>`                                 |
/// | `xsd:extension`           | Dart class inheritance (`extends`)        |

LibraryWithSource? generateFromFile(File xsdSourceFile) {
  try {
    var schema = Schema.fromFile(xsdSourceFile);

    var typeDeclarations = <CodeModel>[];
    typeDeclarations.addAll(generateComplexTypes(schema));
    typeDeclarations.addAll(generateSimpleTypes(schema));

    return LibraryWithSource(
      classes: typeDeclarations.whereType<Class>().toList(),
      enums: typeDeclarations.whereType<Enumeration>().toList(),
      typeDefs: typeDeclarations.whereType<TypeDef>().toList(),
      xsdSourceFile: xsdSourceFile,
      schema: schema,
    );
  } catch (e) {
    log.warning(
      'Error creating Dart code from: ${xsdSourceFile.path} Error: $e',
    );
    return null;
  }
}

const xsdNamespaceUri = 'http://www.w3.org/2001/XMLSchema';

/// represents a [Xml Schema Definition](https://en.wikipedia.org/wiki/XML_Schema_(W3C))
class Schema extends XmlElement {
  factory Schema.fromFile(File xsdFile) {
    var xmlString = xsdFile.readAsStringSync();
    var document = XmlDocument.parse(xmlString);
    return Schema(document);
  }

  factory Schema(XmlDocument xsdDocument) {
    XmlElement? element = xsdDocument
        .findElements("schema", namespace: xsdNamespaceUri)
        .firstOrNull;

    if (element == null) {
      throw ArgumentError("No schema element found in XSD document");
    }
    return Schema.fromElement(element);
  }

  Schema.fromElement(XmlElement schema)
    : super(
        schema.name.copy(),
        List<XmlAttribute>.from(schema.attributes.map((a) => a.copy())),
        List<XmlNode>.from(schema.children.map((c) => c.copy())),
        schema.isSelfClosing,
      );

  String? findNameSpaceUri(String nameSpacePrefixToFind) {
    for (var attribute in attributes) {
      if (attribute.name.prefix == 'xmlns' &&
          attribute.name.local == nameSpacePrefixToFind) {
        return attribute.value;
      }
    }
    return null;
  }
}

String findTypeName(XmlElement xsdElement) {
  var name = xsdElement.getAttribute('name');
  if (name != null && name.isNotEmpty) {
    return toValidDartNameStartingWitUpperCase(name);
  }

  var parent = xsdElement.parent;
  if (parent is XmlElement &&
      (parent.name.local == 'element' || parent.name.local == 'attribute')) {
    name = parent.getAttribute('name');
    return toValidDartNameStartingWitUpperCase(name);
  }

  throw ArgumentError('It or its parent has no name attribute');
}
