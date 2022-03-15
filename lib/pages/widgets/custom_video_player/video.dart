import 'package:auto_orientation/auto_orientation.dart';
import 'package:custom_video_player/pages/widgets/custom_video_player/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'advanced_overlay_widget.dart';
import 'models/m3u8.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String url;
  final List<double> speeds;
  const CustomVideoPlayer({
    Key? key,
    required this.url,
    this.speeds = const [0.25, 0.5, 1, 1.5, 1.75, 2],
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool _isShowControl = false;
  VideoPlayerController? _controller;

  List<M3U8pass> _m3u8s = [];
  M3U8pass? _currentQuality;

  @override
  void initState() {
    super.initState();
    initController();
  }

  void initController() {
    final url = widget.url;
    VideoFormat? format = videoFormat(url);
    if (_controller == null) {
      _controller = VideoPlayerController.network(url, formatHint: format)
        ..addListener(() {
          setState(() {});
        })
        ..setLooping(true)
        ..initialize().then(
          (_) => _controller?.play(),
        );
      if (format == VideoFormat.hls) {
        getM3U8(url);
      }
    }
  }

  void resetControllerOnQualityChange(M3U8pass quality) async {
    final url = quality.dataURL;
    if (url != null) {
      setState(() {
        _currentQuality = quality;
      });
      _controller?.pause();
      final seekTo = _controller?.value.position ?? const Duration(seconds: 0);
      _controller =
          VideoPlayerController.network(url, formatHint: VideoFormat.hls)
            ..addListener(() {
              setState(() {});
            })
            ..setLooping(true)
            ..initialize().then(
              (_) {
                _controller?.play();
                _controller?.seekTo(seekTo);
              },
            );
    }
  }

  void getM3U8(String url) async {
    _m3u8s.clear();
    _m3u8s = await loadM3U8s(url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
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
                    speeds: widget.speeds,
                    m3u8s: _m3u8s,
                    currentM3u8: _currentQuality,
                    isFullscreen: !isPortrait,
                    controller: _controller!,
                    onClickedFullScreen: () {
                      !isPortrait
                          ? AutoOrientation.portraitUpMode()
                          : AutoOrientation.landscapeRightMode();
                    },
                    onChangeQuality: (value) {
                      resetControllerOnQualityChange(value);
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
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );

    final size = _controller!.value.size;
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
