import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lat_hdr_transcoder/lat_hdr_transcoder.dart';
import 'package:photo_manager/photo_manager.dart';

import 'pick/photos_button.dart';
import 'pick/picker_button.dart';
import 'presentation/selected_video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? selectedVideoPath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          leading: PickerButton(
            onSelectedPickFile: (pickFile) {
              selectedVideoPath = pickFile.xfile.path;
              setState(() {});
            },
          ),
          actions: [
            IconButton.outlined(
              onPressed: () async {
                final result = await LatHdrTranscoder().clearCache();
                print("clear cache result: $result");
              },
              icon: const Icon(
                Icons.cleaning_services_rounded,
                color: Colors.white,
              ),
            ),
            PhotosButton(
              onSelectedAsset: (asset) async {
                if (asset.type != AssetType.video) {
                  print("Not video file");
                  return;
                }
                File? file = await asset.loadFile(isOrigin: true);
                if (file == null) return;

                final extensionSplit = file.uri.pathSegments.last.split('.');
                final extension = extensionSplit.last;
                debugPrint(file.path);
                if (extension.toLowerCase() != "mp4") {
                  file = await file.rename('${file.path}.mp4');
                }

                selectedVideoPath = file.path;
                setState(() {});
              },
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final path = selectedVideoPath;
    if (path == null) return const SizedBox();

    return SelectedVideo(
      key: ValueKey(path),
      path: path,
      onClear: () {
        selectedVideoPath = null;
        setState(() {});
      },
    );
  }
}
