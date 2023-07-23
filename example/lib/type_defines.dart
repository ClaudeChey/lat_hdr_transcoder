import 'package:photo_manager/photo_manager.dart';

extension AssetTypeExt on AssetType {
  MediaType get mediaType {
    switch (this) {
      case AssetType.image:
        return MediaType.image;
      case AssetType.video:
        return MediaType.video;
      default:
        throw UnsupportedError('Unsupported $this');
    }
  }
}

enum MediaType {
  image,
  video;
}
