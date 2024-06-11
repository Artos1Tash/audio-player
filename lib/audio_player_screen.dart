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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Audio Player'),
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
              value: position.inSeconds.toDouble().clamp(0.0, (duration?.inSeconds ?? 0).toDouble()),
              onChanged: handleSeek,
            ),
            Text(formatDuration(duration ?? Duration.zero)),
            IconButton(
              icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
              onPressed: handlePlayPause,
            ),
            ElevatedButton(
              onPressed: selectFile,
              child: const Text('Select Audio File'),
            ),
          ],
        ),
      ),
    );
  }
}
