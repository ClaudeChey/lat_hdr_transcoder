import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:lat_hdr_transcoder/lat_hdr_transcoder_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // MethodChannelLatHdrTranscoder platform = MethodChannelLatHdrTranscoder();
  const MethodChannel channel = MethodChannel('lat_hdr_transcoder');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
