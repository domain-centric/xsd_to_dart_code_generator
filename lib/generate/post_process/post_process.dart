import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xsd_to_dart_code_generator/generate/dart_code/dart_library.dart';
import 'package:xsd_to_dart_code_generator/generate/post_process/add_choice_interfaces.dart';

abstract class PostProcessor {
  Map<File, Library2> process(Map<File, Library2> libraries);
}

class PostProcessors extends DelegatingList<PostProcessor>
    implements PostProcessor {
  PostProcessors() : super([AddChoiceInterfaces()]);

  @override
  Map<File, Library2> process(Map<File, Library2> libraries) {
    var processedLibraries = libraries;
    for (var postProcessor in this) {
      processedLibraries = postProcessor.process(processedLibraries);
    }
    return processedLibraries;
  }
}

class AddInterfacesForXsdChoiceTypes {}

///TODO post procesing of libraries like:    creating constructors, creating toXml methods, creating fromXml methods,
