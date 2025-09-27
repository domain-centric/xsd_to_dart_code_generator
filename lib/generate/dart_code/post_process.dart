import 'package:dart_code/dart_code.dart';
import 'package:xml/xml.dart';

/// Indicates that a class must be post-processed after generation,
/// because not all information is available at the time of generation.
abstract class PostProcess {}

/// This annotation is used inside a [CodeModel] that implements [PostProcess]
/// It contains the XSD element that was used to generate the class.
/// This information is needed for post processing.
/// It does not generate any code.
class PostProcessAnnotation extends Annotation implements PostProcess {
  final XmlElement sourceXsdElement;

  PostProcessAnnotation(this.sourceXsdElement)
    : super(Type('PostProcessAnnotation'));

  /// A [PostProcessAnnotation] does not generate any code.
  @override
  List<CodeNode> codeNodes(Imports imports) => [];
}
