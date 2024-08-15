import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soloud_test/SoLoud/play.dart';
class PlaySound extends StatefulWidget {
  const PlaySound({required this.audioPath,super.key});

  final String audioPath;

  @override
  State<PlaySound> createState() => _PlaySoundState();
}

class _PlaySoundState extends State<PlaySound> {

  static final Logger _log = Logger('_PlaySoundState');

  late Duration soundLength;

  final Map<SoundHandle, ValueNotifier<bool>> isPaused = {};
  final Map<SoundHandle, ValueNotifier<double>> soundPosition = {};
  StreamSubscription<StreamSoundEvent>? _subscription;

  AudioSource? sound;


  Future<void> playAnotherInstance() async {
    if (sound == null) {
      if (!(await loadAsset())) return;
    }

    final newHandle = await SoLoud.instance.play(sound!);

    isPaused[newHandle] = ValueNotifier(false);
    soundPosition[newHandle] = ValueNotifier(0);
  }
  // load music
  Future<bool> loadAsset() async {
    final AudioSource? newSound1;
    newSound1 = await SoLoud.instance.loadAsset(widget.audioPath);

    soundLength = SoLoud.instance.getLength(newSound1);
    sound = newSound1;

    /// Listen to this sound events
    _subscription = sound!.soundEvents.listen((eventResult) {
      _log.fine('Received StreamSoundEvent ${eventResult.event}');

      /// if handle has been stopped of has finished to play
      if (eventResult.event == SoundEventType.handleIsNoMoreValid) {
        isPaused.remove(eventResult.handle);
        soundPosition.remove(eventResult.handle);
      }

      /// if the sound has been disposed
      if (eventResult.event == SoundEventType.soundDisposed) {
        isPaused.clear();
        soundPosition.clear();
        _subscription?.cancel();
        sound = null;
      }
      if (mounted) setState(() {});
    },
    );
    return true;
  }

  @override
  void initState() {
    loadAsset();
    super.initState();
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            await playAnotherInstance();
            if (mounted) setState(() {});
          },
          child: const Text('load'),
        ),
        if (sound != null)
          SoundPlayer(
            handle: sound!.handles.elementAt(0),
            soundLength: soundLength,
            onStopped: () {
              if (mounted) setState(() {});
            },
          ),
      ],
    );
  }
}
