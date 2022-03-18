import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoProgressIndicator extends StatefulWidget {
  const CustomVideoProgressIndicator({
    Key? key,
    required this.controller,
    this.colors = const VideoProgressColors(),
    this.height = 16,
  }) : super(key: key);

  final VideoPlayerController controller;

  final VideoProgressColors colors;

  final double height;

  @override
  _CustomVideoProgressIndicatorState createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator> {
  _CustomVideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;
  bool _controllerWasPlaying = false;
  double _currentScrubPosition = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (controller.value.isInitialized && box != null && box.hasSize) {
      final scrubSize = box.size.height;
      final indicatorHeight = 2 * box.size.height / 3;
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;
      _currentScrubPosition =
          (box.size.width * position / duration) - scrubSize / 2;
      if (_currentScrubPosition < 0) {
        _currentScrubPosition = 0;
      }
      if (_currentScrubPosition > box.size.width - scrubSize) {
        _currentScrubPosition = box.size.width - scrubSize;
      }

      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      void seekToRelativePosition(Offset globalPosition) {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final Offset tapPos = box.globalToLocal(globalPosition);
        final double relative = tapPos.dx / box.size.width;
        final Duration position = controller.value.duration * relative;
        controller.seekTo(position);
      }

      return SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
                top: (widget.height - indicatorHeight) / 2,
                bottom: (widget.height - indicatorHeight) / 2,
                child: SizedBox(
                  height: indicatorHeight,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      LinearProgressIndicator(
                        value: maxBuffering / duration,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                        backgroundColor: colors.backgroundColor,
                      ),
                      LinearProgressIndicator(
                        value: position / duration,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.playedColor),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                )),
            Positioned(
                left: _currentScrubPosition,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (DragStartDetails details) {
                    if (!controller.value.isInitialized) {
                      return;
                    }
                    _controllerWasPlaying = controller.value.isPlaying;
                    if (_controllerWasPlaying) {
                      controller.pause();
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    if (!controller.value.isInitialized) {
                      return;
                    }
                    seekToRelativePosition(details.globalPosition);
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    if (_controllerWasPlaying &&
                        controller.value.position !=
                            controller.value.duration) {
                      controller.play();
                    }
                  },
                  child: Container(
                      height: scrubSize,
                      width: scrubSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.playedColor,
                      )),
                )),
          ],
        ),
      );
    } else {
      return Container(
        height: widget.height,
        padding: EdgeInsets.symmetric(vertical: widget.height / 6),
        child: LinearProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
          backgroundColor: colors.backgroundColor,
        ),
      );
    }
  }
}
