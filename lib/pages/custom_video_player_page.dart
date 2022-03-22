import 'package:flutter/material.dart';

import 'widgets/custom_video_player/video.dart';

class CustomVideoPlayerPage extends StatefulWidget {
  const CustomVideoPlayerPage({Key? key}) : super(key: key);

  @override
  _CustomVideoPlayerPageState createState() => _CustomVideoPlayerPageState();
}

const urlLandscapeVideo =
    "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8";
const urlPortraitVideo =
    'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4';

class _CustomVideoPlayerPageState extends State<CustomVideoPlayerPage> {
  bool _fullScreen = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: _fullScreen
          ? null
          : AppBar(
              title: const Text('Custom video player'),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomVideoPlayer(
              url: urlLandscapeVideo,
              onFullScreen: (value) {
                setState(() {
                  _fullScreen = value;
                });
              },
            ),
            !_fullScreen ? _buildDescription() : Container(),
          ],
        ),
      ),
    ));
  }

  Widget _buildDescription() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Subtitle',
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Click me'),
            )
          ],
        ),
      );
}
