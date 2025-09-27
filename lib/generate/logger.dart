import 'package:logging/logging.dart';

final log = Logger('MyApp');

void initLog() {
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
