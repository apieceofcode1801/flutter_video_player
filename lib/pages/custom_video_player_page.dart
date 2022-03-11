import 'package:auto_orientation/auto_orientation.dart';
import 'package:custom_video_player/pages/widgets/advanced_overlay_widget.dart';
import 'package:custom_video_player/pages/widgets/video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerPage extends StatefulWidget {
  const CustomVideoPlayerPage({Key? key}) : super(key: key);

  @override
  _CustomVideoPlayerPageState createState() => _CustomVideoPlayerPageState();
}

const urlLandscapeVideo =
    'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
const urlPortraitVideo =
    'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4';

class _CustomVideoPlayerPageState extends State<CustomVideoPlayerPage> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      urlLandscapeVideo,
    )
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true)
      ..initialize().then(
        (_) => _controller.play(),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        debugPrint('$orientation');
        final isPortrait = orientation == Orientation.portrait;
        return SafeArea(
            top: false,
            child: Scaffold(
                appBar: isPortrait
                    ? AppBar(
                        title: const Text('Custom video player'),
                      )
                    : null,
                body: _controller.value.isInitialized
                    ? _buildContent(isPortrait: isPortrait)
                    : const Center(
                        child: CircularProgressIndicator(),
                      )));
      },
    );
  }

  Widget _buildContent({required bool isPortrait}) => Container(
        alignment: Alignment.topCenter,
        child: isPortrait
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 200, child: Video(controller: _controller)),
                _buildDescription(),
              ])
            : Video(
                controller: _controller,
                isPortrait: false,
              ),
      );

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
            TextButton(onPressed: () {}, child: const Text('Click me'))
          ],
        ),
      );
}
