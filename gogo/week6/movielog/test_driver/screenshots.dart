import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await Directory('evidence/week4').create(recursive: true);
      await File('evidence/week4/$name.png').writeAsBytes(bytes);
      return true;
    },
  );
}
