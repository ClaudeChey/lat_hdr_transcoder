import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lat_hdr_transcoder_platform_interface.dart';

/// An implementation of [LatHdrTranscoderPlatform] that uses method channels.
class MethodChannelLatHdrTranscoder extends LatHdrTranscoderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lat_hdr_transcoder');

  @override
  Future<bool?> isHDR(String path) {
    return methodChannel.invokeMethod<bool>('isHDR', {'path': path});
  }

  @override
  Future<String?> transcode(String path) {
    return methodChannel.invokeMethod<String>('transcode', {'path': path});
  }
}
