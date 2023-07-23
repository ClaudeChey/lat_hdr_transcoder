import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'media_thumb.dart';

class MediaListPage extends StatefulWidget {
  const MediaListPage({super.key});

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  List<AssetPathEntity> paths = [];
  AssetPathEntity? selectePath;
  int selectedPathCount = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result != PermissionState.authorized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Requires permissions')));
      }
      return;
    }
    _fetchAssetPaths();
  }

  Future<void> _fetchAssetPaths() async {
    paths = await PhotoManager.getAssetPathList(type: RequestType.video);
    selectePath = paths.first;
    selectedPathCount = await selectePath!.assetCountAsync;
    setState(() {});
  }

  Future<void> _showBottomSheetPaths() async {
    final futureActions = paths.map((e) async {
      final count = await e.assetCountAsync;
      return BottomSheetAction(
        title: Text('${e.name} ($count)'),
        onPressed: (context) {
          selectePath = e;
          selectedPathCount = count;
          setState(() {});
          Navigator.pop(context);
        },
      );
    }).toList();
    final actions = await Future.wait(futureActions);
    if (mounted) {
      showAdaptiveActionSheet(
        context: context,
        actions: actions,
        cancelAction: CancelAction(title: const Text('Cancel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTitle() {
    final path = selectePath;
    if (path == null) {
      return const SizedBox();
    }

    return TextButton(
      onPressed: _showBottomSheetPaths,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${path.name} ($selectedPathCount)',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_drop_down_circle_rounded,
            color: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    final path = selectePath;
    if (path == null) {
      return const SizedBox();
    }

    return FutureBuilder(
      future: path.getAssetListPaged(page: 0, size: 1000),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return _buildGridView(data);
      },
    );
  }

  Widget _buildGridView(List<AssetEntity> entities) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context, entity);
          },
          child: MediaThumb(key: ValueKey(index), entity: entity),
        );
      },
    );
  }
}
