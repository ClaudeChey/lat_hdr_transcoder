# lat_hdr_transcoder

[![pub package](https://img.shields.io/pub/v/lat_hdr_transcoder.svg)](https://pub.dartlang.org/packages/lat_hdr_transcoder)

The purpose of this plugin is clear and simple

It checks if the video file is in HDR format and converts HDR video to SDR<br/>
The conversion utilizes the capabilities of the native platform (Android, iOS)<br/>
(FFMPEG is not utilized)

Be sure to check the minimum supported version

See the [example app](https://github.com/ClaudeChey/lat_hdr_transcoder/blob/main/example/lib/main.dart) for more details

<br/>

# Android

`transcoding` supported 29+

# iOS

`isHdr` supported 14+

# How to use

## Check HDR format

```dart
bool isHdr = await LatHdrTranscoder().isHdr(String path)
```

## Transcoding

```dart
LatHdrTranscoder().onProgress.listen(dynamic value) {
    print(value) // 0.0 to 1.0
}

String? sdrVideoPath = await LatHdrTranscoder().transcoding(String path)
```

## Clear cache

```dart
bool success = await LatHdrTranscoder().clearCache()
```
