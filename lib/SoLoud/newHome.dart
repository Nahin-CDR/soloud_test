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

  @override
  void initState() {
    super.initState();
    _initializeSound();
  }

  Future<void> _initializeSound() async {
    sound = await SoLoud.instance.loadFile(widget.audioPath, mode: LoadMode.memory);
    if (sound != null) {
      soundLength = SoLoud.instance.getLength(sound!);
      handle = await SoLoud.instance.play(sound!, paused: true); // Play initially paused
      _startTimer();
    }
    setState(() {});
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (handle != null) {
        soundPosition.value = SoLoud.instance.getPosition(handle!);
      }
    });
  }

  void _togglePlayPause() async {
    if (handle != null) {
      SoLoud.instance.pauseSwitch(handle!);
      isPlaying.value = !SoLoud.instance.getPause(handle!);
    }
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
                    SoLoud.instance.stop(handle!);
                    soundPosition.value = Duration.zero;
                    isPlaying.value = false;
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

