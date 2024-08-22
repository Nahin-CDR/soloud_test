import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../SoLoud/newHome.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {

  final audioRecorderNew = AudioRecorder();


   Future<void> startRecording() async {
     try{
       final isSupported = await audioRecorderNew.isEncoderSupported(AudioEncoder.aacLc);
       if (kDebugMode) {
         print("${AudioEncoder.aacLc.name} supported : $isSupported");
       }

       final dir = await getApplicationDocumentsDirectory();
       final path = '${dir.path}/audio0_${DateTime.now().millisecondsSinceEpoch}.wav';

       Timer(const Duration(milliseconds: 10), () async {
         await audioRecorderNew.start(
           const RecordConfig(
               noiseSuppress: true,
               encoder: AudioEncoder.wav,
               bitRate: 128000,//32000,
               echoCancel: true
           ),
           path: path,
         );
       });

     }catch(e) {
       if(kDebugMode){
         print("Error occurred : ${e}");
       }
     }
   }

   String recordedAudioPath = "";

   Future<void>stopRecording() async {
     final path = await audioRecorderNew.stop();
     if(path != null) {
       setState(() {
         recordedAudioPath = path;
       });
       print("recordedAudioPath : $recordedAudioPath");
     }
   }







  @override
  void initState() {
    // TODO: implement initState


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: (){
                  startRecording();
                },
                child:const Text("Start Recording")
            ),

            const SizedBox(height:100),

            ElevatedButton(
                onPressed: (){
                  stopRecording();
                },
                child:const Text("Stop Recording")
            ),

            const SizedBox(height:100),

            ElevatedButton(
                onPressed: (){
                  // Navigate to next screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewHomeScreen(audioPath: recordedAudioPath)
                      )
                  );  // Replace with your desired screen
                },
                child: const Text("Next Screen")
            )


          ],
        ),
      ),
    );
  }
}
