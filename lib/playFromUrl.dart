import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class PlayFromURL extends StatefulWidget {
  const PlayFromURL({super.key, required this.url});

  final String url;

  @override
  State<PlayFromURL> createState() => _PlayFromURLState();
}

class _PlayFromURLState extends State<PlayFromURL> {
  final Logger _log = Logger('_NewHomeScreenState');
  AudioSource? sound;
  SoundHandle? handle;
  Timer? timer;
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  late Duration soundLength;
  StreamSubscription<StreamSoundEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeSound();
  }

  Future<void> _initializeSound() async {
    try {
      sound = await SoLoud.instance.loadUrl(widget.url);
      if (sound != null) {
        soundLength = SoLoud.instance.getLength(sound!);
        _prepareAndPlay();
        _startTimer();
      }
    } catch (error) {
      _log.severe('Error loading sound: $error');
    }
    setState(() {});
  }

  Future<void> _prepareAndPlay() async {
    try {
      handle = await SoLoud.instance.play(sound!, paused: true); // Initially paused
      _subscription = sound!.soundEvents.listen((eventResult) {
        if (eventResult.event == SoundEventType.handleIsNoMoreValid) {
          _resetPlayer();
        }
      });
    } catch (error) {
      _log.severe('Error preparing sound: $error');
    }
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (handle != null) {
        soundPosition.value = SoLoud.instance.getPosition(handle!);
        if (soundPosition.value >= soundLength) {
          _resetPlayer();
        }
      }
    });
  }

  void _togglePlayPause() async {
    if (handle != null) {
      SoLoud.instance.pauseSwitch(handle!);
      isPlaying.value = !SoLoud.instance.getPause(handle!);
    }
    setState(() {});
  }

  void _resetPlayer() {
    soundPosition.value = Duration.zero;
    isPlaying.value = false;
    _prepareAndPlay(); // Reset the audio to its initial state
  }

  @override
  void dispose() {
    timer?.cancel();
    _subscription?.cancel();
    SoLoud.instance.stop(handle!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!SoLoud.instance.isInitialized || sound == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
