import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';
import 'package:xsd_to_dart_code_generator/generate/generator/check_unique_names.dart';

/// This class is a placeholder for a class that needs to be post-processed
/// to add the correct superclass and constructor.
class ClassFromXsd extends Class implements HasMappedXsdElements {
  /// the elements that are mapped to /created this class
  @override
  final List<XmlElement> mappedXsdElements;
  ClassFromXsd(
    super.name, {
    super.docComments,
    super.annotations,
    super.modifier,
    super.superClass,
    super.implements,
    super.mixins,
    super.fields,
    super.constructors,
    super.methods,
    required this.mappedXsdElements,
  }) {
    if (mappedXsdElements.isEmpty) {
      throw ArgumentError(
        'Must contain at least one mapped xsd element',
        'mappedXsdElements',
      );
    }
  }

  ClassFromXsd copyWith({
    String? name,
    List<DocComment>? docComments,
    List<Annotation>? annotations,
    ClassModifier? modifier,
    Type? superClass,
    List<Type>? implements,
    List<Type>? mixins,
    List<Field>? fields,
    List<Constructor>? constructors,
    List<Method>? methods,
    List<XmlElement>? xsdSources,
  }) {
    return ClassFromXsd(
      name ?? this.name.toString(),
      docComments: docComments ?? this.docComments,
      annotations: annotations ?? this.annotations,
      modifier: modifier ?? this.modifier,
      superClass: superClass ?? this.superClass,
      implements: implements ?? this.implements,
      mixins: mixins ?? this.mixins,
      fields: fields ?? this.fields,
      constructors: constructors ?? this.constructors,
      methods: methods ?? this.methods,
      mappedXsdElements: xsdSources ?? this.mappedXsdElements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassFromXsd &&
        name == other.name &&
        mappedXsdElements == other.mappedXsdElements;
  }

  @override
  int get hashCode => Object.hash(name, mappedXsdElements);
}

// class ClassThatNeedsNoConstructor extends ClassFromXsd {
//   ClassThatNeedsNoConstructor(
//     super.name, {
//     super.docComments,
//     super.annotations,
//     super.abstract,
//     super.implements,
//     super.mixins,
//     super.fields,
//     super.methods,
//     required super.mappedXsdElements,
//   });
// }
