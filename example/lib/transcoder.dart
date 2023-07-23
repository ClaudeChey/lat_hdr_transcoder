import 'package:flutter/services.dart';
import 'package:lat_hdr_transcoder/lat_hdr_transcoder.dart';
import 'package:light_compressor/light_compressor.dart';

class Transcoder {
  Transcoder({required this.path});
  final String path;

  Future<String?> transcoding() async {
    throw UnimplementedError();
  }
}

class TranscoderLatHdr extends Transcoder {
  TranscoderLatHdr({required super.path});

  @override
  Future<String?> transcoding() async {
    try {
      return LatHdrTranscoder().transcode(path);
    } on PlatformException catch (e) {
      print(e);
    }

    return null;
  }
}

class TranscoderLightCompresor extends Transcoder {
  TranscoderLightCompresor({required super.path});

  @override
  Future<String?> transcoding({String filename = 'name'}) async {
    final compressor = LightCompressor();
    final subscription = compressor.onProgressUpdated.listen((event) {
      print(event);
    });
    final result = await compressor.compressVideo(
        path: path,
        videoQuality: VideoQuality.high,
        android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: false),
        video: Video(videoName: filename));

    String? resultPath;
    if (result is OnSuccess) {
      resultPath = result.destinationPath;
    } else if (result is OnFailure) {
      print(result.message);
    } else if (result is OnCancelled) {
      print(result.isCancelled);
    }
    subscription.cancel();

    return resultPath;
  }
}
