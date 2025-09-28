import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';

/// This class is a placeholder for a class that needs to be post-processed
/// to add the correct superclass and constructor.
class ClassToBePostProcessed extends Class {
  /// the element that created this class
  final XmlElement xsdSource;
  ClassToBePostProcessed(
    super.name, {
    super.docComments,
    super.annotations,
    super.abstract,
    super.superClass,
    super.implements,
    super.mixins,
    super.fields,
    super.constructors,
    super.methods,
    required this.xsdSource,
  });

  ClassToBePostProcessed copyWith({
    String? name,
    List<DocComment>? docComments,
    List<Annotation>? annotations,
    bool? abstract,
    Type? superClass,
    List<Type>? implements,
    List<Type>? mixins,
    List<Field>? fields,
    List<Constructor>? constructors,
    List<Method>? methods,
    XmlElement? xsdSource,
  }) {
    return ClassToBePostProcessed(
      name ?? this.name.toString(),
      docComments: docComments ?? this.docComments,
      annotations: annotations ?? this.annotations,
      abstract: abstract ?? this.abstract,
      superClass: superClass ?? this.superClass,
      implements: implements ?? this.implements,
      mixins: mixins ?? this.mixins,
      fields: fields ?? this.fields,
      constructors: constructors ?? this.constructors,
      methods: methods ?? this.methods,
      xsdSource: xsdSource ?? this.xsdSource,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassToBePostProcessed &&
        name == other.name &&
        xsdSource == other.xsdSource;
  }

  @override
  int get hashCode => Object.hash(name, xsdSource);
}
