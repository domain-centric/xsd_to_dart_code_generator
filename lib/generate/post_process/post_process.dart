import 'package:collection/collection.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/post_process/add_choice_interfaces.dart';
import 'package:xsd_to_dart_code_generator/generate/post_process/add_mapped_types.dart';

abstract class PostProcessor {
  List<LibraryWithSource> generateOrImprove(List<LibraryWithSource> libraries);
}

class PostProcessors extends DelegatingList<PostProcessor>
    implements PostProcessor {
  PostProcessors() : super([AddChoiceInterfaces(), AddMappedTypes()]);

  @override
  List<LibraryWithSource> generateOrImprove(List<LibraryWithSource> libraries) {
    for (var postProcessor in this) {
      libraries = postProcessor.generateOrImprove(libraries);
    }
    return libraries;
  }
}

class AddInterfacesForXsdChoiceTypes {}

///TODO post procesing of libraries like:    creating constructors, creating toXml methods, creating fromXml methods,
