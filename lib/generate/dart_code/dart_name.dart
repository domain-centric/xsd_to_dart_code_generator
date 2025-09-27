import 'package:dart_code/dart_code.dart';
import 'package:change_case/change_case.dart';

final RegExp _notLettersNumbersUnderscoreOrDollar = RegExp(r'[^\w\$]');

String toValidDartNameStartingWitLowerCase(String? name) {
  if (name == null) {
    throw ArgumentError("Name cannot be null");
  }

  var candidate = name.toLowerFirstCase().replaceAll(
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
