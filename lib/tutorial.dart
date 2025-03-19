import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:provider/provider.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isError = false;
            _controller.pause();
          });
        }
      }).catchError((error) {
        print("Video error: $error"); // Debugging log
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isError = true;
          });
        }
      });

    _controller.setLooping(true);
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LanguageProvider>();
    final isFilipino = provider.isFilipino;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 237),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 100, 122, 99),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _isError
                                ? Center(
                                    child: Text("Failed to load video.",
                                        style: TextStyle(color: Colors.white)))
                                : AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  ),
                      ),
                    ),
                    if (!_isLoading && !_isError)
                      Positioned(
                        bottom: 5,
                        left: 10,
                        child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          onPressed: _togglePlayPause,
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color.fromARGB(255, 113, 140, 110),
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                Image.asset(
                  isFilipino ? 'assets/tagalog.png' : 'assets/info.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
