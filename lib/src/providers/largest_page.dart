import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2/fsm2.dart';
import '../svg/size.dart';

final largestPageProvider =
    StateNotifierProvider<LargestPageProvider, LargestPage>(
        LargestPageProvider.new);

class LargestPageProvider extends StateNotifier<LargestPage> {
  LargestPageProvider(Ref ref) : super(LargestPage(ref));
}

class LargestPage extends StateNotifier<Size> {
  LargestPage(this.ref) : super(Size(0, 0));
  Ref ref;

  void update(List<SMCatFile> pages) {
    findLargestPage(pages);
  }

  Size get largestPage => state;

  void findLargestPage(List<SMCatFile> pages) {
    final largest = Size(0, 0);
    for (final smcatFile in pages) {
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
