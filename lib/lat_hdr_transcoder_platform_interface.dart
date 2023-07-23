import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lat_hdr_transcoder_method_channel.dart';

abstract class LatHdrTranscoderPlatform extends PlatformInterface {
  /// Constructs a LatHdrTranscoderPlatform.
  LatHdrTranscoderPlatform() : super(token: _token);

  static final Object _token = Object();

  static LatHdrTranscoderPlatform _instance = MethodChannelLatHdrTranscoder();

  /// The default instance of [LatHdrTranscoderPlatform] to use.
  ///
  /// Defaults to [MethodChannelLatHdrTranscoder].
  static LatHdrTranscoderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LatHdrTranscoderPlatform] when
  /// they register themselves.
  static set instance(LatHdrTranscoderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> isHDR(String path) {
    throw UnimplementedError('isHDR() has not been implemented.');
  }

  Future<String?> transcode(String path) {
    throw UnimplementedError('transcode() has not been implemented.');
  }
}
