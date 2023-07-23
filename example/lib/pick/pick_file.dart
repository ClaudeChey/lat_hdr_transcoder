import 'package:image_picker/image_picker.dart';

import '../type_defines.dart';

class PickFile {
  PickFile({required this.xfile, required this.mediaType});

  final XFile xfile;
  final MediaType mediaType;

  @override
  String toString() {
    return '${xfile.name}, $mediaType';
  }
}
