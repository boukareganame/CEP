// lesson_detail_screen.dart (suite)
import 'package:flutter/material.dart';
import 'course_service.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class LessonDetailScreen extends StatefulWidget {
  final int lessonId;

  LessonDetailScreen({required this.lessonId});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Future<Map<String, dynamic>> _lesson;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  double _volume = 1.0; // Volume initial

  @override
  void initState() {
    super.initState();
    _lesson = CourseService.getLessonDetails(widget.lessonId);
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails de la leçon')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _lesson,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final lesson = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson['titre'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  if (lesson['video_url'] != null)
                    FutureBuilder(
                      future: _initializeVideoPlayer(lesson['video_url']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Column(
                            children: [
                              AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                              VideoProgressIndicator(_videoController!, allowScrubbing: true),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                    onPressed: () {
                                      setState(() {
                                        _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  if (lesson['image_url'] != null)
                    Image.network(lesson['image_url']),
                  if (lesson['audio_url'] != null)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_isPlaying) {
                              await _audioPlayer!.pause();
                            } else {
                              await _audioPlayer!.play(UrlSource(lesson['audio_url']));
                            }
                          },
                          child: Text(_isPlaying ? 'Pause Audio' : 'Play Audio'),
                        ),
                        Slider(
                          value: _volume,
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                              _audioPlayer?.setVolume(value);
                            });
                          },
                        ),
                        StreamBuilder<Duration>(
                          stream: _audioPlayer?.onPositionChanged,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Slider(
                                value: snapshot.data!.inMilliseconds.toDouble(),
                                max: _audioPlayer?.getDuration()?.inMilliseconds.toDouble() ?? 100,
                                onChanged: (value) async {
                                  await _audioPlayer?.seek(Duration(milliseconds: value.toInt()));
                                },
                              );
                            } else {
                              return Slider(value: 0, onChanged: null);
                            }
                          },
                        ),
                      ],
                    ),
                  if (lesson['texte'] != null)
                    Text(lesson['texte']),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoController!.initialize();
  }
}