import 'package:dart_code/dart_code.dart';

Type? convertXsdTypeToDartType(String xsdType, {required bool isNullable}) {
  isNullable = isNullable || xsdType.endsWith("?");
  var safeType = xsdType.replaceAll("?", "");
  switch (safeType) {
    // bool
    case "boolean":
      return Type.ofBool(nullable: isNullable);
    // int
    case "int":
    case "byte":
    case "short":
    case "long":
    case "unsignedLong":
    case "unsignedInt":
    case "unsignedShort":
    case "unsignedByte":
    case "positiveInteger":
    case "nonNegativeInteger":
    case "nonPositiveInteger":
    case "negativeInteger":
    case "integer":
      return Type.ofInt(nullable: isNullable);
    // double
    case "double":
    case "decimal":
    case "float":
      return Type.ofDouble(nullable: isNullable);
    // String
    case "string":
    case "language":
    case "anyURI":
    case "token":
    case "QName":
    case "Name":
    case "NCName":
    case "ENTITY":
    case "ID":
    case "IDREF":
    case "NMTOKEN":
    case "NOTATION":
      return Type.ofString(nullable: isNullable);
    // date and time
    case "dateTime":
      return Type.ofDateTime(nullable: isNullable);
    // Uint8List
    case "base64Binary":
    case "hexBinary":
      return Type('Uint8List', nullable: isNullable);
    // List<String>
    case "ENTITIES":
    case "IDREFS":
    case "NMTOKENS":
      return Type.ofList(genericType: Type.ofString(), nullable: isNullable);
    // duration
    case "duration":
      return Type.ofDuration(nullable: isNullable);
    default:
      return null;
  }
}

// FIXME: remove
// String? generateDartListTypedef(String simpleTypeName, String itemType) {
//   return "typedef $simpleTypeName = List<${convertXsdTypeToDartType(itemType, isNullable: false)}>;\n";
// }
