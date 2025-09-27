import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_file.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_name.dart';
import 'package:collection/collection.dart';

/// FIXME move to dart_code package
/// Represents a dart enumeration declaration.
/// See [https://dart.dev/guides/language/language-tour#classes]
class Enumeration extends CodeModel {
  final List<DocComment>? docComments;
  final List<Annotation>? annotations;
  final IdentifierStartingWithUpperCase name;
  final List<Type>? implements;
  final List<IdentifierStartingWithLowerCase> values;
  final List<Constructor>? constructors;
  final List<Method>? methods;

  Enumeration(
    String name,
    Set<String> values, {
    this.docComments,
    this.annotations,
    this.implements,
    this.constructors,
    this.methods,
  }) : name = IdentifierStartingWithUpperCase(name),
       values = values.map((e) => IdentifierStartingWithLowerCase(e)).toList();

  @override
  List<CodeNode> codeNodes(Imports imports) => [
    if (docComments != null) ...docComments!,
    if (annotations != null) ...annotations!,
    KeyWord.enum$,
    Space(),
    name,
    Space(),
    if (implements != null) KeyWord.implements$,
    if (implements != null) Space(),
    if (implements != null) SeparatedValues.forParameters(implements!),
    if (implements != null) Space(),
    Block([
      for (var value in values) ...[
        value,
        if (value != values.last) Code(','),
        NewLine(),
      ],
      if (constructors != null) SeparatedValues.forStatements(constructors!),
      if (methods != null) SeparatedValues.forStatements(methods!),
    ]),
  ];
}

Enumeration? createEnum(String enumName, XmlElement restriction) {
  var enumerationElements = restriction
      .findElements('enumeration', namespace: xsdNamespaceUri)
      .toList();
  if (enumerationElements.isEmpty) {
    throw ArgumentError('restriction does not have any enumeration children');
  }

  var enumValues = EnumerationValues();
  for (var enumElement in enumerationElements) {
    var xmlEnumValue = enumElement.getAttribute('value');
    var dartEnumValue = toValidDartNameStartingWitLowerCase(
      xmlEnumValue ?? '',
    ).toString();
    var enumValue = EnumerationValue(
      xmlValue: xmlEnumValue!,
      dartValue: dartEnumValue,
    );
    enumValues.add(enumValue);
  }

  if (enumValues.isEmpty) {
    throw ArgumentError('No valid enumeration values found');
  }

  return EnumerationWithXmlValues(enumName, enumValues);
}

/// A wrapper on [Enumeration] so we can store the [enumValues] needed for XML conversion
class EnumerationWithXmlValues extends Enumeration {
  final EnumerationValues enumValues;
  EnumerationWithXmlValues(String name, this.enumValues)
    : super(name, enumValues.map((v) => v.dartValue).toSet());
}

/// Holds both the enum value for dart and XML, needed for XML conversion
class EnumerationValue {
  final String xmlValue;
  final String dartValue;

  EnumerationValue({required this.xmlValue, required this.dartValue});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumerationValue &&
          runtimeType == other.runtimeType &&
          xmlValue == other.xmlValue &&
          dartValue == other.dartValue;

  @override
  int get hashCode => xmlValue.hashCode ^ dartValue.hashCode;

  @override
  String toString() => 'EnumValue(xmlValue: $xmlValue, dartValue: $dartValue)';
}

/// convenience class for XML conversion
class EnumerationValues extends DelegatingSet<EnumerationValue> {
  EnumerationValues() : super(<EnumerationValue>{});

  String? dartValueForXmlValue(String xmlValue) {
    return firstWhereOrNull((e) => e.xmlValue == xmlValue)?.dartValue;
  }

  String? xmlValueForDartValue(String xmlValue) {
    return firstWhereOrNull((e) => e.xmlValue == xmlValue)?.xmlValue;
  }
}
