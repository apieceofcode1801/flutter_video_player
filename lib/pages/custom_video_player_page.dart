import 'package:auto_orientation/auto_orientation.dart';
import 'package:custom_video_player/pages/widgets/advanced_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerPage extends StatefulWidget {
  const CustomVideoPlayerPage({Key? key}) : super(key: key);

  @override
  _CustomVideoPlayerPageState createState() => _CustomVideoPlayerPageState();
}

class _CustomVideoPlayerPageState extends State<CustomVideoPlayerPage> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
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
        return Scaffold(
            appBar: isPortrait
                ? AppBar(
                    title: const Text('Custom video player'),
                  )
                : null,
            body: _controller.value.isInitialized
                ? _buildContent(isPortrait: isPortrait)
                : const Center(
                    child: CircularProgressIndicator(),
                  ));
      },
    );
  }

  Widget _buildContent({required bool isPortrait}) => Container(
        alignment: Alignment.topCenter,
        child: isPortrait
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Video(controller: _controller),
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

class Video extends StatefulWidget {
  final bool isPortrait;
  final VideoPlayerController controller;
  const Video({Key? key, this.isPortrait = true, required this.controller})
      : super(key: key);

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  bool _isShowControl = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isShowControl = !_isShowControl;
        });
      },
      child: Stack(
        fit: widget.isPortrait ? StackFit.loose : StackFit.expand,
        children: [
          buildVideoPlayer(),
          _isShowControl
              ? Positioned.fill(
                  child: AdvancedOverlayWidget(
                    controller: widget.controller,
                    onClickedFullScreen: () {
                      widget.isPortrait
                          ? AutoOrientation.landscapeRightMode()
                          : AutoOrientation.portraitUpMode();
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildVideoPlayer() {
    final video = AspectRatio(
      aspectRatio: widget.controller.value.aspectRatio,
      child: VideoPlayer(widget.controller),
    );

    final size = widget.controller.value.size;
    final width = size.width;
    final height = size.height;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: width,
        height: height,
        child: video,
      ),
    );
  }
}
