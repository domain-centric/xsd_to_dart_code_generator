import 'package:xml/xml.dart';

import 'package:dart_code/dart_code.dart';
import 'package:change_case/change_case.dart';

String findTypeName(
  XmlElement xsdElement,
  XsdNamePathToTypeNameMapping nameMapping,
) {
  var namePathList = findXsdNamePath(xsdElement);
  if (namePathList.isEmpty) {
    throw ArgumentError('Xsd element or its parents have no name attribute');
  }

  var namePath = namePathList.join('.');
  if (nameMapping.keys.contains(namePath)) {
    var name = nameMapping[namePath];
    return toValidDartNameStartingWitUpperCase(name);
  }

  var name = namePathList.last;
  return toValidDartNameStartingWitUpperCase(name);
}

List<String> findXsdNamePath(
  XmlElement element, [
  List<String>? foundXsdNames,
]) {
  foundXsdNames = foundXsdNames ?? [];
  var nameAttribute = element.getAttribute('name');
  if (nameAttribute != null) {
    foundXsdNames.insert(0, nameAttribute);
  }
  if (element.parentElement == null) {
    return foundXsdNames;
  }
  var parent = element.parentElement!;
  return findXsdNamePath(parent, foundXsdNames);
}

final RegExp _notLettersNumbersUnderscoreOrDollar = RegExp(r'[^\w\$]');

String toValidDartNameStartingWitLowerCase(String? name) {
  if (name == null) {
    throw ArgumentError("Name cannot be null");
  }

  var candidate = name.toCamelCase().toLowerFirstCase().replaceAll(
    _notLettersNumbersUnderscoreOrDollar,
    '',
  );
  if (KeyWord.allNames.contains(candidate)) {
    candidate = "$candidate\$";
  }

  /// throws an error when still invalid
  return IdentifierStartingWithLowerCase(candidate).toString();
}

String toValidDartNameStartingWitUpperCase(String? name) {
  if (name == null) {
    throw ArgumentError("Name cannot be null");
  }
  var candidate = name.toUpperFirstCase().replaceAll(
    _notLettersNumbersUnderscoreOrDollar,
    '',
  );
  if (KeyWord.allNames.contains(candidate)) {
    candidate = "$candidate\$";
  }

  /// throws an error when still invalid
  return IdentifierStartingWithUpperCase(candidate).toString();
}

/// Allows the developer to map names, e.g.:
/// {'ParameterSet.OutputVars.Variable': 'OutputVariable'}
typedef XsdNamePathToTypeNameMapping = Map<String, String>;
