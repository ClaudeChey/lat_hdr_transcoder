import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lat_hdr_transcoder/lat_hdr_transcoder.dart';

import 'video_view.dart';

class SelectedVideo extends StatefulWidget {
  const SelectedVideo({
    super.key,
    required this.path,
    required this.onClear,
  });

  final String path;
  final void Function() onClear;

  @override
  State<SelectedVideo> createState() => _SelectedVideoState();
}

class _SelectedVideoState extends State<SelectedVideo> {
  bool? isHdr;
  String? convertedPath;
  bool converting = false;

  StreamSubscription? updateProgress;
  double progress = 0;

  @override
  void dispose() {
    updateProgress?.cancel();
    updateProgress = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.path);
  }

  Future<void> _converting() async {
    updateProgress = LatHdrTranscoder().onProgress.listen((event) {
      progress = event;
      setState(() {});
    });

    converting = true;
    setState(() {});

    try {
      convertedPath = await LatHdrTranscoder().transcoding(widget.path, 1);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }

    converting = false;
    updateProgress?.cancel();
    setState(() {});
    debugPrint(convertedPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('origin path:\n${widget.path}'),
        const SizedBox(height: 8),
        if (convertedPath != null) Text('converted path:\n$convertedPath'),
        if (isHdr != null) Text('HDR: $isHdr'),
        _buildCheckHdrButton(),
        _buildConvertButton(),
        _buildVideo(),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildCheckHdrButton() {
    return ElevatedButton(
      onPressed: () async {
        isHdr = await LatHdrTranscoder().isHdr(widget.path);
        setState(() {});
      },
      child: const Text('1. check HDR'),
    );
  }

  Widget _buildConvertButton() {
    if (converting) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator.adaptive(),
          ),
          Text((progress * 100).toStringAsFixed(0)),
        ],
      );
    }

    return ElevatedButton(
      onPressed: isHdr == true ? _converting : null,
      child: const Text('2. Convert'),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: widget.onClear,
      child: const Text('Clear'),
    );
  }

  Widget _buildVideo() {
    final path = convertedPath ?? widget.path;

    return Container(
      color: Colors.grey,
      width: 300,
      height: 300,
      alignment: Alignment.center,
      child: VideoView(path: path),
    );
  }
}
