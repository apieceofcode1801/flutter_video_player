import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AdvancedOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onClickedFullScreen;

  static const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

  const AdvancedOverlayWidget({
    Key? key,
    required this.controller,
    this.onClickedFullScreen,
  }) : super(key: key);

  String getPosition() {
    final duration = Duration(
        milliseconds: controller.value.position.inMilliseconds.round());

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
        margin: const EdgeInsets.all(8).copyWith(right: 0),
        height: 16,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      );

  Widget buildTop() => Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton<double>(
              initialValue: controller.value.playbackSpeed,
              tooltip: 'Playback speed',
              onSelected: controller.setPlaybackSpeed,
              itemBuilder: (context) => allSpeeds
                  .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                        value: speed,
                        child: Text('${speed}x'),
                      ))
                  .toList(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  '${controller.value.playbackSpeed}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 28,
              ),
              onTap: onClickedFullScreen,
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
                controller.seekTo(
                    (await controller.position)! - const Duration(seconds: 10));
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
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 70,
              ),
            ),
            onTap: () {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            },
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
              onPressed: () async {
                controller.seekTo(
                    (await controller.position)! + const Duration(seconds: 10));
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
