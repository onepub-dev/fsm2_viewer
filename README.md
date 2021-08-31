# fsm2_viewer

FSM2 Viewer is a companion project to [FSM2](https://github.com/bsutton/fsm2).

FSM2 allows you to programatically define Finite State Machines in Dart.

FSM2 provides an export option which exports the FSM to an smcat file.

The viewer can open an smcat file and have it rendered as an svg file.

The viewer is a flutter desktop application and currently it has only been tested on linux but should work on supported desktop platforms.

![FSM2 View](images/app.png)


# Deploying

## Linux

From the project root run:

```
bin/install_snap.dart
snapcraft
```

To publish the snap:
(requires a developer account at snapcraft.io)

```
 snapcraft login
 snapcraft register

 snapcraft push --release=beta fsm2-viewer.snap
 ```
 


