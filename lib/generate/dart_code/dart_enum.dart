import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/type_name.dart';

// /// FIXME move to dart_code package
// /// Represents a dart enumeration declaration.
// /// See [https://dart.dev/guides/language/language-tour#classes]
// class Enumeration extends CodeModel {
//   final List<DocComment>? docComments;
//   final List<Annotation>? annotations;
//   final IdentifierStartingWithUpperCase name;
//   final List<Type>? implements;
//   final List<IdentifierStartingWithLowerCase> values;
//   final List<Constructor>? constructors;
//   final List<Method>? methods;

//   Enumeration(
//     String name,
//     Set<String> values, {
//     this.docComments,
//     this.annotations,
//     this.implements,
//     this.constructors,
//     this.methods,
//   }) : name = IdentifierStartingWithUpperCase(name),
//        values = values.map((e) => IdentifierStartingWithLowerCase(e)).toList();

//   @override
//   List<CodeNode> codeNodes(Imports imports) => [
//     if (docComments != null) ...docComments!,
//     if (annotations != null) ...annotations!,
//     KeyWord.enum$,
//     Space(),
//     name,
//     Space(),
//     if (implements != null) KeyWord.implements$,
//     if (implements != null) Space(),
//     if (implements != null) SeparatedValues.forParameters(implements!),
//     if (implements != null) Space(),
//     Block([
//       for (var value in values) ...[
//         value,
//         if (value != values.last) Code(','),
//         NewLine(),
//       ],
//       if (constructors != null) SeparatedValues.forStatements(constructors!),
//       if (methods != null) SeparatedValues.forStatements(methods!),
//     ]),
//   ];
// }

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
