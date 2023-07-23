import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaThumb extends StatefulWidget {
  const MediaThumb({super.key, required this.entity});

  final AssetEntity entity;

  @override
  State<MediaThumb> createState() => _MediaThumbState();
}

class _MediaThumbState extends State<MediaThumb> {
  Uint8List? _thumb;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchThumb();
  }

  Future<void> _fetchThumb() async {
    _thumb = await widget.entity
        .thumbnailDataWithSize(const ThumbnailSize.square(300));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = _thumb;
    if (data == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onPrimary,
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      );
    }

    final duration = widget.entity.duration > 0 ? widget.entity.duration : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          data,
          fit: BoxFit.cover,
        ),
        if (duration != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${duration}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}
