import 'dart:async';

import 'dart:io';

var _controller = StreamController<FileSystemEvent>();

typedef OnChanged = void Function();

void _notifyNone() {}

OnChanged _onChanged = _notifyNone;

void watchDirectory(String directory, {OnChanged onChanged = _notifyNone}) {
  _onChanged = onChanged;
  // ignore: avoid_print
  print('watching $directory');
  Directory(directory)
      .watch(events: FileSystemEvent.all)
      .listen((event) => _controller.add(event));
}

void onFileSystemEvent(FileSystemEvent event) {
  _onChanged();
  // if (event is FileSystemCreateEvent) {
  //   onCreateEvent(event);
  // } else if (event is FileSystemModifyEvent) {
  //   onModifyEvent(event);
  // } else if (event is FileSystemMoveEvent) {
  //   onMoveEvent(event);
  // } else if (event is FileSystemDeleteEvent) {
  //   onDeleteEvent(event);
  // }
}
