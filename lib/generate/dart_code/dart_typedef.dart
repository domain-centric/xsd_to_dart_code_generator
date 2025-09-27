import 'package:dart_code/dart_code.dart';

class TypeDef extends CodeModel {
  TypeDef({
    required this.name,
    required this.type,
    this.docComments,
    this.annotations,
  });

  final String name;
  final Type type;
  final List<DocComment>? docComments;
  final List<Annotation>? annotations;

  @override
  List<CodeNode> codeNodes(Imports imports) => [
    if (docComments != null) ...docComments!,
    if (annotations != null) ...annotations!,
    KeyWord.typedef$,
    Space(),
    type,
    Code(';'),
  ];
}
