import 'dart:io';

import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/generator.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_enum.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_typedef.dart';
import 'package:xsd_to_dart_code_generator/generate/from_xsd/generate_from_simple_type.dart';
import 'package:xsd_to_dart_code_generator/generate/logger.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';

class AddLibraryForEachXsdFile implements GeneratorStage {
  final Directory xsdDirectory;
  AddLibraryForEachXsdFile(this.xsdDirectory);

  @override
  List<LibraryWithSource> generate(List<LibraryWithSource> libraries) {
    List<File> xsdFiles = xsdDirectory
        .listSync(recursive: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.xsd'))
        .toList();

    var libraries = <LibraryWithSource>[];

    for (var xsdFile in xsdFiles) {
      var library = generateFromFile(xsdFile);

      if (library != null) {
        libraries.add(library);
      }
    }
    return libraries;
  }
}

/// Converts a xsd file to a Library (from the dart_code package)
/// Strategy:
///
/// | XSD Construct             | Dart Equivalent                           |
/// |---------------------------|-------------------------------------------|
/// | `xsd:complexType`         | Dart class                                |
/// | `xsd:element`             | Dart field                                |
/// | `xsd:attribute`           | Dart field                                |
/// | `xsd:sequence`            | Ordered fields                            |
/// | `xsd:choice`              | One of several fields (can be polymorphic)|
/// | `xsd:group`               | Dart class or reused field group          |
/// | `minOccurs="0"`           | Optional field (nullable)                 |
/// | `maxOccurs="unbounded"`   | `List<T>`                                 |
/// | `xsd:extension`           | Dart class inheritance (`extends`)        |

LibraryWithSource? generateFromFile(File xsdSourceFile) {
  try {
    var schema = Schema.fromFile(xsdSourceFile);

    var typeDeclarations = <CodeModel>[];
    typeDeclarations.addAll(generateSimpleTypes(schema));

    return LibraryWithSource(
      classes: typeDeclarations.whereType<Class>().toList(),
      enums: typeDeclarations.whereType<Enumeration>().toList(),
      typeDefs: typeDeclarations.whereType<TypeDef>().toList(),
      xsdSourceFile: xsdSourceFile,
      schema: schema,
    );
  } catch (e) {
    log.warning(
      'Error creating Dart code from: ${xsdSourceFile.path} Error: $e',
    );
    return null;
  }
}
