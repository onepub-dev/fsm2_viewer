#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

void main() {
  'snap install snapcraft --classic'.start(privileged: true);
  'snap install multipass --classic'.start(privileged: true);
}
