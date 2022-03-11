import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'advanced_overlay_widget.dart';

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
        fit: StackFit.expand,
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

    return Container(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: SizedBox(
          width: width,
          height: height,
          child: video,
        ),
      ),
    );
  }
}
