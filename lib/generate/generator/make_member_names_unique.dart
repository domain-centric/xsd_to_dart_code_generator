import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';

class MakeMemberNamesUnique extends GeneratorStage {
  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    for (var library in libraries) {
      var namesAndMembers = findNamesWitMembers(library);
      var allNames = namesAndMembers.keys;
      var namesThatAreNotUnique = allNames
          .where((name) => allNames.where((n) => n == name).length > 1)
          .toSet();
      if (namesThatAreNotUnique.isNotEmpty) {
        //FIXME implement making names longer when needed
        log.warning(namesThatAreNotUnique.join(', '));
      }
    }
    return libraries;
  }

  Map<String, CodeModel> findNamesWitMembers(LibraryWithSource library) {
    var namesAndMembers = <String, CodeModel>{};
    for (var clasz in library.classes ?? []) {
      namesAndMembers[clasz.name.toString()] = clasz;
    }
    for (var enumeration in library.enums ?? []) {
      namesAndMembers[enumeration.name.toString()] = enumeration;
    }
    return namesAndMembers;
  }
}
