import 'dart:io';

import 'main_android.dart' as android_entry;
import 'main_windows.dart' as windows_entry;

void main() {
  if (Platform.isWindows) {
    windows_entry.main();
  } else {
    android_entry.main();
  }
}
