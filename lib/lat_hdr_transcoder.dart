import 'package:flutter/services.dart';

class LatHdrTranscoder {
  factory LatHdrTranscoder() => _instance;
  static final LatHdrTranscoder _instance = LatHdrTranscoder._();
  LatHdrTranscoder._();

  static const _methodChannel = MethodChannel('lat_hdr_transcoder');
  static const _progressStream = EventChannel('lat_hdr_transcode/stream');

  Stream<double>? _onProgressUpdated;

  Stream<double> get onProgressUpdated {
    _onProgressUpdated ??= _progressStream
        .receiveBroadcastStream()
        .map<double>((dynamic value) => value ?? 0);
    return _onProgressUpdated!;
  }

  Future<bool?> isHDR(String path) {
    return _methodChannel.invokeMethod<bool>('isHDR', {'path': path});
  }

  Future<String?> transcode(String path) {
    return _methodChannel.invokeMethod<String>('transcode', {'path': path});
  }

  Future<bool?> clearCache() {
    return _methodChannel.invokeMethod<bool>('clearCache');
  }
}
