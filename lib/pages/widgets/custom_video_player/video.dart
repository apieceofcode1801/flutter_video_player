import 'dart:async';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:custom_video_player/pages/widgets/custom_video_player/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'advanced_overlay_widget.dart';
import 'models/m3u8.dart';

class CustomVideoPlayer extends StatefulWidget {
  final double aspectRatio;
  final String url;
  final List<double> speeds;
  final Function(bool value)? onFullScreen;
  const CustomVideoPlayer({
    Key? key,
    required this.url,
    this.onFullScreen,
    this.aspectRatio = 16 / 9,
    this.speeds = const [0.25, 0.5, 1, 1.5, 1.75, 2],
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool fullScreen = false;
  bool _isShowControl = false;
  VideoPlayerController? _controller;

  Timer? _controlShowTimer;

  List<M3U8pass> _m3u8s = [];
  M3U8pass? _currentQuality;

  late VoidCallback listener;

  _CustomVideoPlayerState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    handleOrientationChanges();
    initController();
  }

  void handleOrientationChanges() {
    final widgetsBinding = WidgetsBinding.instance!;

    widgetsBinding.addPostFrameCallback((callback) {
      widgetsBinding.addPersistentFrameCallback((callback) {
        var orientation = MediaQuery.of(context).orientation;
        bool? _fullscreen;
        if (orientation == Orientation.landscape) {
          //Horizontal screen
          _fullscreen = true;
        } else if (orientation == Orientation.portrait) {
          _fullscreen = false;
        }
        if (_fullscreen != fullScreen) {
          fullScreen = !fullScreen;
          if (widget.onFullScreen != null) {
            widget.onFullScreen!(fullScreen);
          }
          _navigateLocally(context);
          // setState(() {});
        }
        //
        widgetsBinding.scheduleFrame();
      });
    });
  }

  void initController() {
    final url = widget.url;
    VideoFormat? format = videoFormat(url);
    if (_controller == null) {
      _controller = VideoPlayerController.network(url, formatHint: format)
        ..addListener(listener)
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
            ..addListener(listener)
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
    final videoView = GestureDetector(
      onTap: () {
        _handleShowControl();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                  child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )),
            ),
          ),
          _isShowControl
              ? Positioned.fill(
                  child: AdvancedOverlayWidget(
                    speeds: widget.speeds,
                    m3u8s: _m3u8s,
                    currentM3u8: _currentQuality,
                    isFullscreen: !isPortrait,
                    controller: _controller!,
                    onClickedFullScreen: toggleFullScreen,
                    onChangeQuality: (value) {
                      resetControllerOnQualityChange(value);
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
    final screenSize = MediaQuery.of(context).size;
    return AspectRatio(
      aspectRatio: fullScreen
          ? calculateAspectRatio(context, screenSize)
          : widget.aspectRatio,
      child: videoView,
    );
  }

  void _navigateLocally(context) async {
    if (!fullScreen) {
      if (ModalRoute.of(context)!.willHandlePopInternally) {
        Navigator.of(context).pop();
      }
      return;
    }
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: () {}));
  }

  void toggleFullScreen() {
    fullScreen
        ? AutoOrientation.portraitUpMode()
        : AutoOrientation.landscapeRightMode();
  }

  void _handleShowControl() {
    _clearShowControlTimer();
    if (!_isShowControl) {
      _controlShowTimer = Timer(const Duration(seconds: 3), () {
        if (_isShowControl) {
          setState(() {
            _isShowControl = false;
          });
        }
      });
    }
    setState(() {
      _isShowControl = !_isShowControl;
    });
  }

  _clearShowControlTimer() {
    _controlShowTimer?.cancel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controlShowTimer?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller?.removeListener(listener);
    super.deactivate();
  }
}

double calculateAspectRatio(BuildContext context, Size screenSize) {
  final width = screenSize.width;
  final height = screenSize.height;
  return width > height ? width / height : height / width;
}
