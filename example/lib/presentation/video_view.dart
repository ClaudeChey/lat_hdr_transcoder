import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.path});

  final String path;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with WidgetsBindingObserver {
  late VideoPlayerController controller;
  bool _isInit = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initController();
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path == widget.path) return;

    _isInit = false;
    setState(() {});
    controller.dispose();
    initController();
  }

  Future<void> initController() async {
    controller = VideoPlayerController.file(File(widget.path));
    controller.setLooping(true);
    controller.play();
    controller.initialize().then((value) {
      _isInit = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) return const SizedBox();
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}
