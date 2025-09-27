import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_enum.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_simple_type_generator.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_file.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

List<CodeModel> generateSimpleTypes(Schema schema) {
  final simpleTypes = schema.findAllElements(
    'simpleType',
    namespace: xsdNamespaceUri,
  );

  final typeDefinitions = <CodeModel>[];
  for (var simpleType in simpleTypes) {
    var typeDefinition = generate(simpleType);
    if (typeDefinition != null) {
      typeDefinitions.add(typeDefinition);
    }
  }

  return typeDefinitions;
}

CodeModel? generate(XmlElement simpleType) {
  if (isInsideOtherSimpleType(simpleType)) {
    // e.g. when inside a union ignore for now
    return null;
  }

  String typeName;
  try {
    typeName = findTypeName(simpleType);
  } catch (e) {
    log.warning(
      'Could not find a valid Dart type name. Error: $e For: $simpleType',
    );
    return null;
  }

  var nestedElements = findNestedElements([simpleType]);

  var restriction = nestedElements.last
      .findElements("restriction", namespace: xsdNamespaceUri)
      .firstOrNull;

  if (restriction != null) {
    var enums = restriction.findElements(
      "enumeration",
      namespace: xsdNamespaceUri,
    );
    if (enums.isNotEmpty) {
      try {
        return createEnum(typeName, restriction);
      } catch (e) {
        log.warning('$e for: $simpleType');
        return null;
      }
    }

    var base = restriction.getAttribute("base")?.split(":").last;
    if (base != null) {
      var valField = Field(
        "val",
        type: convertXsdTypeToDartType(base, isNullable: false),
      );
      return Class(typeName, fields: [valField]);
    }
  }

  var list = simpleType
      .findElements("list", namespace: xsdNamespaceUri)
      .firstOrNull;

  // Typedefs for list types
  if (list != null) {
    var itemType = list.getAttribute("itemType")?.split(":").last;
    if (itemType == null) return null;
    return Statement([
      Code(
        'typedef $typeName = '
        'List<${convertXsdTypeToDartType(itemType, isNullable: false)}>',
      ),
    ]);
  }
  log.warning('Could not generate type from: $simpleType');
  return null;
}

bool isInsideOtherSimpleType(XmlElement simpleType) =>
    simpleType.parentElement == null
    ? false
    : isSimpleType(simpleType.parentElement!) ||
          isInsideOtherSimpleType(simpleType.parentElement!);

bool isSimpleType(XmlElement xsd) =>
    xsd.name.namespaceUri == xsdNamespaceUri && xsd.name.local == 'simpleType';

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
  List<String> candidateNames = ["union", "simpleType"];
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
