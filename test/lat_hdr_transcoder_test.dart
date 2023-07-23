import 'package:flutter_test/flutter_test.dart';
// import 'package:lat_hdr_transcoder/lat_hdr_transcoder.dart';
import 'package:lat_hdr_transcoder/lat_hdr_transcoder_platform_interface.dart';
import 'package:lat_hdr_transcoder/lat_hdr_transcoder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLatHdrTranscoderPlatform
    with MockPlatformInterfaceMixin
    implements LatHdrTranscoderPlatform {
  @override
  Future<bool?> isHDR(String path) {
    // TODO: implement isHDR
    throw UnimplementedError();
  }

  @override
  Future<String?> transcode(String path) {
    // TODO: implement transcode
    throw UnimplementedError();
  }
}

void main() {
  final LatHdrTranscoderPlatform initialPlatform =
      LatHdrTranscoderPlatform.instance;

  test('$MethodChannelLatHdrTranscoder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLatHdrTranscoder>());
  });

  // test('getPlatformVersion', () async {
  //   LatHdrTranscoder latHdrTranscoderPlugin = LatHdrTranscoder();
  //   MockLatHdrTranscoderPlatform fakePlatform = MockLatHdrTranscoderPlatform();
  //   LatHdrTranscoderPlatform.instance = fakePlatform;

  //   expect(await latHdrTranscoderPlugin.getPlatformVersion(), '42');
  // });
}
