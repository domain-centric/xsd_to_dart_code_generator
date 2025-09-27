import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_name.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_simple_type_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_doc_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/post_process.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_file.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

List<Field> generateFieldsFromXsdElement({
  required Schema schema,
  required String typeName,
  required XmlElement complexType,
}) {
  var nestedElements = findNestedElements([complexType]);

  var nestedChoice = findNestedChoiceElement(nestedElements);
  if (nestedChoice != null) {
    var name = nestedChoice.getAttribute('name');
    var isList = _isList(nestedChoice);

    /// create a generic type (an interface) for all generated classes inside choice implement later
    List<XmlElement> elementsThatImplementThisType = findElements(
      schema,
      nestedChoice,
    );
    if (isList) {
      name = name ?? 'items';

      var genericType = XsdChoiceType(
        '${typeName}Item',
        elementsThatImplementThisType,
      );
      return [Field(name, type: Type.ofList(genericType: genericType))];
    } else {
      name = name ?? 'item';

      var genericType = XsdChoiceType(
        '${typeName}Item',
        elementsThatImplementThisType,
      );
      return [Field(name, type: genericType)];
    }
  }

  var fieldXsds = <XmlElement>[
    ...findElements(schema, nestedElements.last),
    ...findAttributes(schema, nestedElements.last),
    if (nestedElements.last != complexType)
      ...findAttributes(schema, complexType),
  ];

  var fields = <Field>[];
  for (var fieldXsd in fieldXsds) {
    var field = convertToField(schema, fieldXsd);
    if (field != null) fields.add(field);
  }

  return fields;
}

XmlElement? findNestedChoiceElement(List<XmlElement> nestedElements) {
  if (nestedElements.last.childElements.length != 1) {
    return null;
  }
  var child = nestedElements.last.childElements.first;
  if (child.localName != 'choice') {
    return null;
  }
  return child;
}

List<XmlElement> findNestedElements(List<XmlElement> foundSoFar) {
  var found = findNestedElement(foundSoFar.last);
  if (found == null) {
    return foundSoFar;
  }

  /// find rest recursively
  foundSoFar.add(found);
  return findNestedElements(foundSoFar);
}

XmlElement? findNestedElement(XmlElement element) {
  List<String> candidateNames = [
    "complexContent",
    "extension",
    "sequence",
    "all",
  ];
  if (element.childElements.isEmpty) {
    return null;
  }
  var child = element.childElements.first;
  if (child.name.namespaceUri == xsdNamespaceUri &&
      candidateNames.contains(child.name.local)) {
    return child;
  }
  return null;
}

Field? convertToField(Schema schema, XmlElement xsd) {
  var xmlName = xsd.getAttribute("name")!;
  String fieldName = toValidDartNameStartingWitLowerCase(xmlName);
  var type = createTypeForElement(schema, xsd);
  if (type == null) {
    log.warning('Dart type could not be determined for: $xsd');
    return null;
  }
  var doc = generateDartDocFromXsdElement(xsd);
  var isElement = xsd.name.local == 'element';
  if (isElement) {
    return XsdElementField(
      fieldName,
      type: type,
      xsdElement: xsd,
      docComments: doc ?? [],
    );
  }
  return XsdAttributeField(
    fieldName,
    type: type,
    xsdAttribute: xsd,
    docComments: doc ?? [],
  );
}

/// A [Field] that represents a XsdElement
class XsdElementField extends Field {
  final XmlElement xsdElement;

  XsdElementField(
    super.name, {

    super.docComments = const [],
    super.annotations = const [],
    super.static = false,
    super.modifier = Modifier.var$,
    super.type,
    super.value,
    required this.xsdElement,
  });
}

/// A [Field] that represents a XsdAttribute
class XsdAttributeField extends Field {
  final XmlElement xsdAttribute;

  XsdAttributeField(
    super.name, {

    super.docComments = const [],
    super.annotations = const [],
    super.static = false,
    super.modifier = Modifier.var$,
    super.type,
    super.value,
    required this.xsdAttribute,
  });
}

Type? createTypeForElement(Schema schema, XmlElement xsd) {
  Type? type;
  type = createFromTypeAttribute(schema, xsd);
  if (type != null) {
    return type;
  }

  type = createFromNameAttribute(schema, xsd);
  if (type != null) {
    return type;
  }
  return null;
}

/// A reference to another (to be) generated class or generated enum
/// [libraryUri] to be defined during post processing
class XsdReferenceType extends Type implements PostProcess {
  final XmlElement xsdElement;
  final String xsdNamespaceUri;

  XsdReferenceType(
    super.name, {
    super.libraryUri,
    super.generics = const [],
    super.nullable = false,
    required this.xsdElement,
    required this.xsdNamespaceUri,
  });
}

Type? createFromTypeAttribute(Schema schema, XmlElement xsd) {
  var typeAttribute = xsd.getAttribute("type");

  if (typeAttribute == null) {
    return null;
  }
  var isNullable = _isNullable(xsd);
  var isList = _isList(xsd);

  var xsdNameSpacePrefix = xsd.name.prefix!;

  if (typeAttribute.startsWith(xsdNameSpacePrefix)) {
    var type = convertXsdTypeToDartType(
      typeAttribute.split(":").last,
      isNullable: isNullable,
    );
    if (type != null) {
      return type;
    }
  }

  // assume it is a reference to another generated class or generated enum
  var namespacePrefix = typeAttribute.split(":").first;
  var namespaceUri = schema.findNameSpaceUri(namespacePrefix) ?? '';
  var typeName = typeAttribute.split(":").last;
  var type = XsdReferenceType(
    typeName,
    xsdElement: xsd,
    xsdNamespaceUri: namespaceUri,
  );

  if (isList) {
    return Type.ofList(genericType: type, nullable: isNullable);
  } else {
    return type;
  }
}

Type? createFromNameAttribute(Schema schema, XmlElement xsd) {
  var name = xsd.getAttribute("name");
  if (name == null) {
    return null;
  }
  var isNullable = _isNullable(xsd);
  var isList = _isList(xsd);

  var type = XsdReferenceType(
    name,
    xsdElement: xsd,
    xsdNamespaceUri: 'TODO',
  ); //TODO:
  if (isList) {
    return Type.ofList(genericType: type, nullable: isNullable);
  } else {
    return type;
  }
}

_isList(XmlElement element) =>
    element.getAttribute("maxOccurs") == "unbounded" ||
    (element.getAttribute("maxOccurs") != null &&
        int.tryParse(element.getAttribute("maxOccurs")!) != null &&
        int.parse(element.getAttribute("maxOccurs")!) > 1);

bool _isNullable(XmlElement element) {
  return element.getAttribute("nillable") == "true" ||
      element.getAttribute("minOccurs") == "0" ||
      element.getAttribute("use") == "optional";
}

class XsdChoiceType extends Type implements PostProcess {
  final List<XmlElement> elementsThatImplementThisType;
  XsdChoiceType(super.name, this.elementsThatImplementThisType);
}

/// finds within [parent] all xds.elements, including xsd.group references
List<XmlElement> findElements(Schema schema, XmlElement parent) {
  var elements = parent
      .findElements('element', namespace: xsdNamespaceUri)
      .toList();

  var groups = parent
      .findElements('group', namespace: xsdNamespaceUri)
      .toList();
  for (var group in groups) {
    var ref = group.getAttribute('ref');
    if (ref == null) {
      continue;
    }
    var groupNameToFind = ref.split(':').last;
    var foundReferredGroups = schema
        .findAllElements('group', namespace: xsdNamespaceUri)
        .where((g) => g.getAttribute('name') == groupNameToFind);
    if (foundReferredGroups.length != 1) {
      log.warning('Could not find group reference: $ref');
      continue;
    }
    var referredGroup = foundReferredGroups.first;
    elements.addAll(findElements(schema, referredGroup));

    /// elements could be inside a choice...
    var choices = referredGroup.findElements(
      'choice',
      namespace: xsdNamespaceUri,
    );
    if (choices.length == 1) {
      var choice = choices.first;
      elements.addAll(findElements(schema, choice));
    }
  }
  return elements;
}

/// finds within [parent] all xsd:attribute elements, including xsd:attributeGroup references
findAttributes(Schema schema, XmlElement parent) {
  var attributes = parent
      .findElements("attribute", namespace: xsdNamespaceUri)
      .toList();

  var groups = parent
      .findElements('attributeGroup', namespace: xsdNamespaceUri)
      .toList();
  for (var group in groups) {
    var ref = group.getAttribute('ref');
    if (ref == null) {
      continue;
    }
    var groupNameToFind = ref.split(':').last;
    var foundReferredGroups = schema
        .findAllElements('group')
        .where((g) => g.name.local == groupNameToFind);
    if (foundReferredGroups.length != 1) {
      log.warning('Could not find group reference: $ref');
      continue;
    }
    var referredGroup = foundReferredGroups.first;
    attributes.addAll(findElements(schema, referredGroup));
  }
  return attributes;
}
