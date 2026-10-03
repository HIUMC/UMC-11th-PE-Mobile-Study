import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final adb = Platform.environment['ANDROID_ADB'];
  Process? recording;
  if (adb != null) {
    recording = await Process.start(adb, [
      '-s',
      'emulator-5554',
      'shell',
      'screenrecord',
      '--time-limit',
      '50',
      '/sdcard/week3-complete-flow.mp4',
    ]);
    recording.stdout.drain<void>();
    recording.stderr.drain<void>();
  }
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await Directory('evidence').create(recursive: true);
      await File('evidence/$name.png').writeAsBytes(bytes);
      return true;
    },
    responseDataCallback: (_) async {
      if (recording != null && adb != null) {
        await recording.exitCode;
        final result = await Process.run(adb, [
          '-s',
          'emulator-5554',
          'pull',
          '/sdcard/week3-complete-flow.mp4',
          'evidence/user-flow.mp4',
        ]);
        if (result.exitCode != 0) {
          throw StateError('영상 저장 실패: ${result.stderr}');
        }
      }
    },
  );
}
