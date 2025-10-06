import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';

/// This class is a placeholder for a class that needs to be post-processed
/// to add the correct superclass and constructor.
class ClassToBePostProcessed extends Class {
  /// the element that created this class
  final List<XmlElement> xsdSources;
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
    required this.xsdSources,
  }) {
    if (xsdSources.isEmpty) {
      throw ArgumentError('Must contain at least one source', 'xsdSources');
    }
  }

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
    List<XmlElement>? xsdSources,
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
      xsdSources: xsdSources ?? this.xsdSources,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassToBePostProcessed &&
        name == other.name &&
        xsdSources == other.xsdSources;
  }

  @override
  int get hashCode => Object.hash(name, xsdSources);
}

class ClassThatNeedsNoConstructor extends ClassToBePostProcessed {
  ClassThatNeedsNoConstructor(
    super.name, {
    super.docComments,
    super.annotations,
    super.abstract,
    super.implements,
    super.mixins,
    super.fields,
    super.methods,
    required super.xsdSources,
  });
}
