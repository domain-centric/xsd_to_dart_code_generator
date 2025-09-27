import 'package:dart_code/dart_code.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_enum.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_typedef.dart';

/// Represents a [Library] containing optional [DocComment]s, [Annotation]s, [DartFunction]s and [Class]es
/// See: [https://www.tutorialspoint.com/dart_programming/dart_programming_libraries.htm#:~:text=A%20library%20in%20a%20programming,typedefs%2C%20properties%2C%20and%20exceptions.]
class Library2 extends Library {
  final List<Enumeration>? enums;
  final List<TypeDef>? typeDefs;

  Library2({
    super.name,
    super.docComments,
    super.annotations,
    super.functions,
    super.classes,
    this.enums,
    this.typeDefs,
  });

  @override
  List<CodeNode> codeNodes(Imports imports) {
    var codeNodes = [
      if (libraryStatement != null) libraryStatement!,
      imports,
      if (docComments != null) ...docComments!,
      if (annotations != null) ...annotations!,
      if (functions != null) SeparatedValues.forStatements(functions!),
      if (classes != null) SeparatedValues.forStatements(classes!),
      if (enums != null) SeparatedValues.forStatements(enums!),
      if (typeDefs != null) SeparatedValues.forStatements(typeDefs!),
    ];
    for (var codeNode in codeNodes) {
      imports.registerLibraries(codeNode, imports);
    }
    return codeNodes;
  }

  Library2 copyWith({
    String? name,
    List<DocComment>? docComments,
    List<Annotation>? annotations,
    List<DartFunction>? functions,
    List<Class>? classes,
    List<Enumeration>? enums,
    List<TypeDef>? typeDefs,
  }) {
    return Library2(
      //FIXME Library has no name field  name: name ?? super.name,
      docComments: docComments ?? this.docComments,
      annotations: annotations ?? this.annotations,
      functions: functions ?? this.functions,
      classes: classes ?? this.classes,
      enums: enums ?? this.enums,
      typeDefs: typeDefs ?? this.typeDefs,
    );
  }
}
