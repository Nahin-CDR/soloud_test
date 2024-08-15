import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soloud_test/SoLoud/PlaySound.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    if(!SoLoud.instance.isInitialized){
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("So Loud "),
      ),
      body: const Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaySound(audioPath: 'assets/audio/song.mp3')
          ],
        ),
      ),
    );
  }
}
