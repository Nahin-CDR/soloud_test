import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key, required this.audioPath});

  final String audioPath;

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final Logger _log = Logger('_NewHomeScreenState');
  AudioSource? sound;
  SoundHandle? handle;
  Timer? timer;
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  late Duration soundLength;
  StreamSubscription<StreamSoundEvent>? streamSubscription;





  @override
  void initState() {
    super.initState();
    _initializeSound();
  }

  // eta just ek bar e call hobe
  Future<void> _initializeSound() async {
    sound = await SoLoud.instance.loadFile(widget.audioPath, mode: LoadMode.memory);
    if (sound != null) {
      soundLength = SoLoud.instance.getLength(sound!);
      _prepareAndPlay();
    }
    setState(() {});
  }

  Future<void> _prepareAndPlay() async {
    handle = await SoLoud.instance.play(sound!, paused: true); // Play initially paused

    streamSubscription = sound!.soundEvents.listen((eventResult) {
      if(eventResult.event == SoundEventType.handleIsNoMoreValid){
        _resetPlayer();
      }
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (handle != null) {
        soundPosition.value = SoLoud.instance.getPosition(handle!);
        if (soundPosition.value+ Duration(milliseconds: 200) >= soundLength) {
          _resetPlayer();
        }
      }
    });
  }

  void _togglePlayPause() async {
    if (handle != null) {
      SoLoud.instance.pauseSwitch(handle!);
      isPlaying.value = !SoLoud.instance.getPause(handle!);
      setState(() {});
    }
  }

  void _resetPlayer() {
    SoLoud.instance.stop(handle!);  // Stop the current playback
    soundPosition.value = Duration.zero;
    isPlaying.value = false;
    _prepareAndPlay(); // Prepare for the next play cycle
    setState(() {});
    print("reset player called");// Ensure UI reflects the reset state
  }

  @override
  void dispose() {
    timer?.cancel();
    SoLoud.instance.stop(handle!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!SoLoud.instance.isInitialized || sound == null) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("So Loud"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isPlaying,
                  builder: (context, playing, child) {
                    return IconButton(
                      onPressed: _togglePlayPause,
                      icon: playing
                          ? const Icon(Icons.pause_circle_outline)
                          : const Icon(Icons.play_circle_outline),
                      iconSize: 48,
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () async {
                    _resetPlayer();
                  },
                  icon: const Icon(Icons.stop_circle_outlined, size: 48),
                ),
              ],
            ),
            ValueListenableBuilder<Duration>(
              valueListenable: soundPosition,
              builder: (context, position, child) {
                final positionText =
                    '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}';
                return Row(
                  children: [
                    Text(positionText),
                    Expanded(
                      child: Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: soundLength.inMilliseconds.toDouble(),
                        onChanged: (double value) {
                          final newPosition = Duration(milliseconds: value.round());
                          soundPosition.value = newPosition;
                          SoLoud.instance.seek(handle!, newPosition);
                        },
                      ),
                    ),
                    Text(soundLength.inSeconds.toString()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
