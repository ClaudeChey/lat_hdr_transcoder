import 'lat_hdr_transcoder_platform_interface.dart';

class LatHdrTranscoder {
  Future<bool?> isHDR(String path) async {
    return LatHdrTranscoderPlatform.instance.isHDR(path);
  }

  Future<String?> transcode(String path) async {
    return LatHdrTranscoderPlatform.instance.transcode(path);
  }
}
