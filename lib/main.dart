import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import 'package:soloud_test/SoLoud/home.dart';
import 'dart:developer' as dev;

import 'package:soloud_test/SoLoud/newHome.dart';

void main() async{

  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace
    );
  });

  WidgetsFlutterBinding.ensureInitialized();


  await SoLoud.instance.init().then((_){
    Logger('main').info('Player started');

    SoLoud.instance.setVisualizationEnabled(true);
    SoLoud.instance.setGlobalVolume(1);
    SoLoud.instance.setMaxActiveVoiceCount(32);
    }, onError: (Object error){
    Logger('main').severe('Failed to initialize SoLoud: $error');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoLoud Demo',
      theme: ThemeData.light(),
      home: const NewHomeScreen(audioPath: 'assets/audio/song.mp3')
    );
  }
}

