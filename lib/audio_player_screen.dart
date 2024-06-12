import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final player = AudioPlayer();
  Duration position = Duration.zero;
  Duration? duration;
  String? fileName;

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void handlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        fileName = result.files.single.name;
      });

      if (filePath != null) {
        try {
          await player.setFilePath(filePath);
          player.positionStream.listen((p) {
            setState(() => position = p);
          });

          player.durationStream.listen((d) {
            setState(() => duration = d);
          });

          player.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              setState(() {
                position = Duration.zero;
              });
              player.pause();
              player.seek(position);
            }
          });
        } catch (e) {
          // Handle error gracefully
          print("Error loading audio: $e");
        }
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
  final Color darkBlue = const Color.fromRGBO(40, 67, 135, 1.0); // Dark blue
  final Color lightBlue = const Color.fromRGBO(173, 216, 230, 1.0); // Light blue
  final Color orange = const Color.fromRGBO(40, 163, 163, 1.0); // Orange
  final Color yellow = const Color.fromRGBO(22, 108, 176, 1.0); // Yellow
  final Color dawnColor = const Color.fromRGBO(14, 63, 119, 1.0); // Dawn color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue, // Light blue background
      appBar: AppBar(
        centerTitle: true,
        title: Text('Audio Player'),
        backgroundColor: Colors.transparent, // Dark blue app bar background
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatDuration(position)),
            Slider(
              min: 0.0,
              max: (duration?.inSeconds ?? 0).toDouble(),
              value: position.inSeconds.toDouble().clamp(
                  0.0, (duration?.inSeconds ?? 0).toDouble()),
              onChanged: handleSeek,
              activeColor: Colors.blue,
              // Orange slider track
              inactiveColor: Colors.blue, // Dawn color for inactive slider track
            ),
            Text(formatDuration(duration ?? Duration.zero)),
            IconButton(
              icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
              onPressed: handlePlayPause,
            ),
            const SizedBox(height: 20),
            fileName != null
                ? Text(
              'Playing: $fileName',
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent), // Yellow color for file name
            )
                : Text(
              'No file selected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: selectFile,
              iconSize: 48,
              tooltip: 'Select Audio File',
              color: darkBlue, // Dark blue color for folder icon
            ),
          ],
        ),
      ),
    );
  }
  }