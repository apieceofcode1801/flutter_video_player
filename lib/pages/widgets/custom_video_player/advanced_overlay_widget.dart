import 'package:custom_video_player/pages/widgets/custom_video_player/top_chip.dart';
import 'package:custom_video_player/pages/widgets/custom_video_player/video_progress.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'models/m3u8.dart';

class AdvancedOverlayWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClickedFullScreen;
  final Function(M3U8pass value) onChangeQuality;
  final VoidCallback onPlayToggled;

  final List<double> speeds;
  final List<M3U8pass>? m3u8s;
  final M3U8pass? currentM3u8;
  final bool isFullscreen;

  final VoidCallback? startChangingProgress;
  final VoidCallback? endChangingProgress;

  const AdvancedOverlayWidget(
      {Key? key,
      required this.controller,
      this.speeds = const [],
      this.m3u8s,
      this.currentM3u8,
      required this.onClickedFullScreen,
      required this.onChangeQuality,
      required this.onPlayToggled,
      required this.isFullscreen,
      this.startChangingProgress,
      this.endChangingProgress})
      : super(key: key);

  @override
  State<AdvancedOverlayWidget> createState() => _AdvancedOverlayWidgetState();
}

class _AdvancedOverlayWidgetState extends State<AdvancedOverlayWidget> {
  bool _showM3u8 = false;
  bool _showSpeed = false;
  @override
  void initState() {
    super.initState();
  }

  String getPosition() {
    final duration = Duration(
        milliseconds: widget.controller.value.position.inMilliseconds.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: <Widget>[
            buildPlay(),
            buildTop(),
            Positioned(
              left: 8,
              bottom: 28,
              child: Text(
                getPosition(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildIndicator(),
            ),
            buildM3u8list(),
            buildSpeedlist(),
          ],
        ),
      );

  Widget buildIndicator() => Container(
        margin: const EdgeInsets.all(8),
        child: CustomVideoProgressIndicator(
          controller: widget.controller,
          height: 16,
          startChangingProgress: widget.startChangingProgress,
          endChangingProgress: widget.endChangingProgress,
        ),
      );

  Widget buildTop() => Align(
        alignment: Alignment.topRight,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.m3u8s != null && widget.m3u8s!.isNotEmpty
                  ? topChip(
                      Text(
                          '${widget.currentM3u8?.dataQuality ?? widget.m3u8s!.first.dataQuality}'),
                      () {
                        setState(() {
                          _showM3u8 = true;
                          _showSpeed = false;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 12),
              widget.speeds.isNotEmpty
                  ? topChip(
                      Text('${widget.controller.value.playbackSpeed}x'),
                      () {
                        setState(() {
                          _showSpeed = true;
                          _showM3u8 = false;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 12),
              GestureDetector(
                child: Icon(
                  widget.isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                  size: 28,
                ),
                onTap: widget.onClickedFullScreen,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );

  Widget buildPlay() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () async {
                widget.controller.seekTo((await widget.controller.position)! -
                    const Duration(seconds: 10));
              },
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
              )),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(70)),
              ),
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 70,
              ),
            ),
            onTap: () {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
              widget.onPlayToggled();
            },
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
              onPressed: () async {
                widget.controller.seekTo((await widget.controller.position)! +
                    const Duration(seconds: 10));
              },
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget buildM3u8list() {
    return _showM3u8
        ? Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 55),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.m3u8s!
                      .map((e) => InkWell(
                            onTap: () {
                              setState(() {
                                _showM3u8 = false;
                              });
                              widget.onChangeQuality(e);
                            },
                            child: Container(
                                width: 90,
                                color: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${e.dataQuality}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ))
                      .toList(),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget buildSpeedlist() {
    return _showSpeed
        ? Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 33),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.speeds
                      .map((e) => InkWell(
                            onTap: () {
                              setState(() {
                                _showSpeed = false;
                              });
                              widget.controller.setPlaybackSpeed(e);
                            },
                            child: Container(
                                width: 90,
                                color: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${e}x',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ))
                      .toList(),
                ),
              ),
            ),
          )
        : Container();
  }
}
