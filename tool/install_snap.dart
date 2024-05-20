#! /usr/bin/env dcli

import 'dart:io';

void main() async {
  await Process.start('snap', ['install', 'snapcraft', '--classic']);
  await Process.start('snap', ['install', 'multipass', '--classic']);
}
