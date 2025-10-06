import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

Enumeration? createEnum(String enumName, XmlElement restriction) {
  var enumerationElements = restriction
      .findElements('enumeration', namespace: xsdNamespaceUri)
      .toList();
  if (enumerationElements.isEmpty) {
    throw ArgumentError('restriction does not have any enumeration children');
  }

  var enumValues = <EnumerationValueWithXmlValue>{};
  for (var enumElement in enumerationElements) {
    var xmlEnumValue = enumElement.getAttribute('value');
    var dartEnumValue = toValidDartNameStartingWitLowerCase(
      xmlEnumValue ?? '',
    ).toString();
    var enumValue = EnumerationValueWithXmlValue(
      xmlValue: xmlEnumValue!,
      dartValue: dartEnumValue,
    );
    enumValues.add(enumValue);
  }

  if (enumValues.isEmpty) {
    throw ArgumentError('No valid enumeration values found');
  }

  return Enumeration(enumName, enumValues);
}

/// convenience class for XML conversion
class EnumerationValueWithXmlValue extends EnumValue {
  final String dartValue;
  final String xmlValue;
  EnumerationValueWithXmlValue({
    required this.dartValue,
    required this.xmlValue,
  }) : super(dartValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumerationValueWithXmlValue &&
          runtimeType == other.runtimeType &&
          dartValue == other.dartValue &&
          xmlValue == other.xmlValue;

  @override
  int get hashCode => dartValue.hashCode ^ xmlValue.hashCode;
}
