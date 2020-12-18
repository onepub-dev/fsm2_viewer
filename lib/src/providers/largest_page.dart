import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2/fsm2.dart';
import 'package:fsm2_viewer/src/svg/size.dart';

final largestPageProvider = StateNotifierProvider((ref) => LargestPage());

class LargestPage extends StateNotifier<Size> {
  LargestPage() : super(Size(0, 0));

  void update(List<SMCatFile> pages) {
    findLargestPage(pages);
  }

  Size get largestPage => state;

  void findLargestPage(List<SMCatFile> pages) {
    Size largest = Size(0, 0);
    for (var smcatFile in pages) {
      if (smcatFile.height > largest.height) {
        largest.height = smcatFile.height;
      }
      if (smcatFile.width > largest.width) {
        largest.width = smcatFile.width;
      }
    }
    state = largest;
  }
}
