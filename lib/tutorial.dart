import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://www.w3schools.com/html/mov_bbb.mp4',
    )
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _isError = false;
          _showControls = true;
        });
        _controller.play(); // Autoplay the video
      }).catchError((error) {
        print("Video Error: $error");
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds if visible
    if (_showControls) {
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showControls = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Video Container
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _isError
                      ? Center(child: Text("Failed to load video."))
                      : GestureDetector(
                          onTap: _toggleControls,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                              // Play/Pause Button
                              if (_showControls)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 30,
                                    child: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
            ),
            SizedBox(height: 20),
            // Header Text
            Text(
              "HOW TO USE SOMO?",
              style: TextStyle(
                color: Color.fromARGB(255, 42, 83, 39),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),
            // Content Container
            Container(
              padding: EdgeInsets.all(10),
              height: 390,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 242, 239, 231),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color.fromARGB(255, 42, 83, 39),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Start Guide:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 42, 83, 39),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "1. Power On and Connect to Wi-Fi\n"
                      "- Turn on the prototype.\n"
                      "- Ensure it's within Farm's Wi-Fi range.\n"
                      "- Wait for sensor calibration.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "2. Place the Soil Sensors\n"
                      "- Insert sensors into the soil.\n"
                      "- Sensors will start measuring.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "3. Download the Mobile App\n"
                      "- Scan the QR code on the enclosure.\n"
                      "- Download and install the app.\n"
                      "- Open the app to view data.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "4. Notifications\n"
                      "- App notifies if levels are abnormal.\n"
                      "- Tap the notification to acknowledge.\n"
                      "- Prototype returns to standby mode.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
