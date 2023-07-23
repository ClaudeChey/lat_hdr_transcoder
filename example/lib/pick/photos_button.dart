import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'media_list_page.dart';

class PhotosButton extends StatelessWidget {
  const PhotosButton({super.key, required this.onSelectedAsset});

  final void Function(AssetEntity asset) onSelectedAsset;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await Navigator.push<AssetEntity?>(
            context,
            CupertinoPageRoute(
              builder: (context) => const MediaListPage(),
              fullscreenDialog: true,
            ));

        if (result == null) return;
        onSelectedAsset(result);
      },
      child: const Icon(
        CupertinoIcons.photo_fill_on_rectangle_fill,
        color: Colors.white,
      ),
    );
  }
}
