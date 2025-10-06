import 'dart:io';

import 'package:xml/xml.dart';

const String xsdNamespaceUri = 'http://www.w3.org/2001/XMLSchema';

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

  late String? targetNameSpaceUri = getAttribute('targetNamespace');
}
