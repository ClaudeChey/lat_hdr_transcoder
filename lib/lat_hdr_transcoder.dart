import 'package:flutter/services.dart';

class LatHdrTranscoder {
  factory LatHdrTranscoder() => _instance;
  static final LatHdrTranscoder _instance = LatHdrTranscoder._();
  LatHdrTranscoder._();

  static const _methodChannel = MethodChannel('lat_hdr_transcoder');
  static const _progressStream = EventChannel('lat_hdr_transcode/stream');

  Stream<double>? _onProgress;

  // Returns the transcoding rate in progress
  // 0.0 to 1.0
  Stream<double> get onProgress {
    _onProgress ??= _progressStream
        .receiveBroadcastStream()
        .map<double>((dynamic value) => value ?? 0);
    return _onProgress!;
  }

  // Make sure the video file is in HDR format
  Future<bool?> isHdr(String path) {
    return _methodChannel.invokeMethod<bool>('isHDR', {'path': path});
  }

  // Convert the HDR video file to SDR
  // Make sure it is HDR before converting
  Future<String?> transcoding(String path) {
    return _methodChannel.invokeMethod<String>('transcoding', {'path': path});
  }

  // Video files converted to SDR are accumulated in a temporary folder
  // It is the developer's responsibility to delete the cache files
  // Delete them at the appropriate time to avoid running out of space on user device
  Future<bool?> clearCache() {
    return _methodChannel.invokeMethod<bool>('clearCache');
  }
}
