import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class SoundPlayer extends StatefulWidget {
  const SoundPlayer({
    required this.handle,
    required this.soundLength,
    required this.onStopped,
    super.key,
  });

  final Duration soundLength;
  final SoundHandle handle;
  final VoidCallback onStopped;

  @override
  State<SoundPlayer> createState() => _SoundPlayerState();
}

class _SoundPlayerState extends State<SoundPlayer> {

  final ValueNotifier<bool> isPaused = ValueNotifier(true);
  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  Timer? timer;


  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      soundPosition.value = SoLoud.instance.getPosition(widget.handle);
    });
  }

  void stopTimer() {
    timer?.cancel();
  }


  @override
  void dispose() {

    timer?.cancel();
    super.dispose();
  }


  // UI portion code
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isPaused,
          builder: (context, paused,child){
            if(paused){
              startTimer();
            }else{
              stopTimer();
            }
            return IconButton(
              onPressed: ()async{
                SoLoud.instance.pauseSwitch(widget.handle);
                isPaused.value = SoLoud.instance.getPause(widget.handle);
                setState(() {});
              } ,
              icon : paused ?
              const Icon(Icons.pause_circle_outline) :
              const Icon(Icons.play_circle_outline),
              iconSize: 48,
            );
          },
        ),

        const SizedBox(width: 16),

        IconButton(
          onPressed: ()async{
            await SoLoud.instance.stop(widget.handle);
            widget.onStopped();
          },
          icon: const Icon(Icons.stop_circle_outlined,size: 48),
        ),
        Expanded(
          child: ValueListenableBuilder<Duration>(
            valueListenable: soundPosition,
            builder: (context,position,child){
              if(position >= widget.soundLength){
                position = Duration.zero;
              }
              final positionText = '${position.inMinutes}:'
                  '${(position.inSeconds %60).toString().padLeft(2,'0')}';
              return Row(
                children: [
                  Text(positionText),
                  Expanded(
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: widget.soundLength < position ?
                      position.inMilliseconds.toDouble() :
                      widget.soundLength.inMilliseconds.toDouble(),
                      onChanged: (double value) {
                        final newPosition = Duration(
                          milliseconds: value.round(),
                        );
                        soundPosition.value = newPosition;
                        SoLoud.instance.seek(widget.handle, newPosition);
                      },
                    ),
                  ),
                  Text(widget.soundLength.inSeconds.toString()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
