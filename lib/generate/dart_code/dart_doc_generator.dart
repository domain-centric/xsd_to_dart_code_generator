import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_file.dart';

List<DocComment>? generateDartDocFromXsdElement(XmlElement element) {
  var annotation = element
      .findElements("annotation", namespace: xsdNamespaceUri)
      .firstOrNull;
  if (annotation != null) {
    var doc = annotation
        .findElements("documentation", namespace: xsdNamespaceUri)
        .firstOrNull
        ?.innerText;
    if (doc == null) return null;
    return [DocComment.fromString(_normalize(doc))];
  }
  return null;
}

String _normalize(String doc) {
  // Write the regex to replace tabs and all other illegal characters
  var illegalChars = RegExp(r'[\t\r\f\v\b]');
  return "/// ${doc.replaceAll(illegalChars, "").replaceAll("\n", "\n/// ")}";
}
