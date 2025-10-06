import 'dart:io';

import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/xsd/schema.dart';

class LibraryWithSource extends Library {
  final File xsdSourceFile;
  final Schema schema;

  LibraryWithSource({
    super.name,
    super.docComments,
    super.annotations,
    super.functions,
    super.classes,
    super.enumerations,
    super.typeDefs,
    required this.xsdSourceFile,
    required this.schema,
  });

  @override
  LibraryWithSource copyWith({
    String? name,
    List<DocComment>? docComments,
    List<Annotation>? annotations,
    List<DartFunction>? functions,
    List<Class>? classes,
    List<Enumeration>? enumerations,
    List<TypeDef>? typeDefs,
    File? xsdSourceFile,
    Schema? schema,
  }) {
    return LibraryWithSource(
      //FIXME Library has no name field  name: name ?? super.name,
      docComments: docComments ?? this.docComments,
      annotations: annotations ?? this.annotations,
      functions: functions ?? this.functions,
      classes: classes ?? this.classes,
      enumerations: enumerations ?? this.enumerations,
      typeDefs: typeDefs ?? this.typeDefs,
      xsdSourceFile: xsdSourceFile ?? this.xsdSourceFile,
      schema: schema ?? this.schema,
    );
  }
}
