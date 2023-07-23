import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../type_defines.dart';
import 'pick_file.dart';

class PickerButton extends StatelessWidget {
  const PickerButton({super.key, required this.onSelectedPickFile});

  final void Function(PickFile pickFile) onSelectedPickFile;

  Future<void> _options(BuildContext context) async {
    final actions = MediaType.values.map((e) {
      return BottomSheetAction(
        title: Text(e.name),
        onPressed: (context) async {
          Navigator.pop(context);
          XFile? result;
          switch (e) {
            case MediaType.image:
              result =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              break;
            case MediaType.video:
              result =
                  await ImagePicker().pickVideo(source: ImageSource.gallery);
              break;
          }
          if (result == null) return;
          onSelectedPickFile(PickFile(xfile: result, mediaType: e));
        },
      );
    }).toList();
    showAdaptiveActionSheet(
      context: context,
      actions: actions,
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _options(context),
      child: const Icon(
        CupertinoIcons.photo,
      ),
    );
  }
}
