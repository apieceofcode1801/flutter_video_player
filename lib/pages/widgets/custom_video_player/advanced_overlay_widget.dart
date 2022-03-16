import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'models/m3u8.dart';

class AdvancedOverlayWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback? onClickedFullScreen;
  final Function(M3U8pass value)? onChangeQuality;

  final List<double> speeds;
  final List<M3U8pass>? m3u8s;
  final M3U8pass? currentM3u8;
  final bool isFullscreen;

  const AdvancedOverlayWidget(
      {Key? key,
      required this.controller,
      this.speeds = const [],
      this.m3u8s,
      this.currentM3u8,
      this.onClickedFullScreen,
      this.onChangeQuality,
      required this.isFullscreen})
      : super(key: key);

  @override
  State<AdvancedOverlayWidget> createState() => _AdvancedOverlayWidgetState();
}

class _AdvancedOverlayWidgetState extends State<AdvancedOverlayWidget> {
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
          ],
        ),
      );

  Widget buildIndicator() => Container(
        margin: const EdgeInsets.all(8),
        height: 16,
        child: VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
        ),
      );

  Widget buildTop() => Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            widget.m3u8s != null && widget.m3u8s!.isNotEmpty
                ? Row(children: [
                    PopupMenuButton<M3U8pass>(
                      initialValue: widget.currentM3u8,
                      onSelected: (value) {
                        if (widget.onChangeQuality != null) {
                          widget.onChangeQuality!(value);
                        }
                      },
                      itemBuilder: (context) => widget.m3u8s!
                          .map<PopupMenuEntry<M3U8pass>>(
                              (m3u8) => PopupMenuItem(
                                    value: m3u8,
                                    child: Text('${m3u8.dataQuality}'),
                                  ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Text(
                            '${widget.currentM3u8?.dataQuality ?? widget.m3u8s!.first.dataQuality}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ])
                : const SizedBox.shrink(),
            PopupMenuButton<double>(
              initialValue: widget.controller.value.playbackSpeed,
              onSelected: widget.controller.setPlaybackSpeed,
              itemBuilder: (context) => widget.speeds
                  .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                        value: speed,
                        child: Text('${speed}x'),
                      ))
                  .toList(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  '${widget.controller.value.playbackSpeed}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              child: Icon(
                widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: 28,
              ),
              onTap: widget.onClickedFullScreen,
            ),
            const SizedBox(width: 8),
          ],
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
}
