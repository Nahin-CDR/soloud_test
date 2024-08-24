import 'dart:async';
import 'dart:io';
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

   Duration timer = const Duration(minutes: 0,seconds: 0);





  @override
  void initState() {
    // TODO: implement initState


    super.initState();
  }

  Timer? _timer;
  Duration _elapsedTime = Duration.zero;



  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();


  }

  @override
  void dispose() {
    _stopTimer(); // Cancel the timer when the widget is disposed
    super.dispose();
  }


  Future<void> deleteRecordedFile() async {
    if (recordedAudioPath.isNotEmpty) {
      final file = File(recordedAudioPath);
      try {
        if (await file.exists()) {
          await file.delete();
          print("File deleted: $recordedAudioPath");
          setState(() {

            //recordedAudioPath = ""; // Clear the path after deletion
          });
          print("File deleted: $recordedAudioPath");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error deleting file: $e");
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String _formattedTime = '${_elapsedTime.inMinutes}:${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  startRecording();
                  _startTimer();
                },
                child:const Text("Start Recording")
            ),

            const SizedBox(height:100),

            ElevatedButton(
                onPressed: (){
                  stopRecording();
                  _stopTimer();
                },
                child:const Text("Stop Recording")
            ),

            const SizedBox(height: 100),

            ElevatedButton(
                onPressed: (){
                  deleteRecordedFile();
                  // Clear the path after deletion
                  //recordedAudioPath = "";  // Clear the path after deletion
                },
                child: Text("Delete")
            ),

            const SizedBox(height:100),

            ElevatedButton(
                onPressed: (){
                  setState(() {
                    _elapsedTime = Duration.zero;
                  });
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
