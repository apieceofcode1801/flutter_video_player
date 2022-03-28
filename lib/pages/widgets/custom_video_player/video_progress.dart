import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoProgressColors {
  const CustomVideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
    this.scrubColor = const Color.fromRGBO(255, 0, 0, 1),
  });
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Color scrubColor;
}

class CustomVideoProgressIndicator extends StatefulWidget {
  const CustomVideoProgressIndicator(
      {Key? key,
      required this.controller,
      this.colors = const CustomVideoProgressColors(),
      this.height = 16,
      this.startChangingProgress,
      this.endChangingProgress})
      : super(key: key);

  final VideoPlayerController controller;

  final CustomVideoProgressColors colors;

  final double height;

  final VoidCallback? startChangingProgress;
  final VoidCallback? endChangingProgress;

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

  CustomVideoProgressColors get colors => widget.colors;
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
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;
      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }
      if (box != null && box.hasSize) {
        final scrubSize = box.size.height;
        final indicatorHeight = 2 * box.size.height / 3;
        _currentScrubPosition =
            (box.size.width * position / duration) - scrubSize / 2;
        if (_currentScrubPosition < 0) {
          _currentScrubPosition = 0;
        }
        if (_currentScrubPosition > box.size.width - scrubSize) {
          _currentScrubPosition = box.size.width - scrubSize;
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colors.bufferedColor),
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
                      if (widget.startChangingProgress != null) {
                        widget.startChangingProgress!();
                      }
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      if (!controller.value.isInitialized) {
                        return;
                      }
                      seekToRelativePosition(details.globalPosition);
                    },
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (widget.endChangingProgress != null) {
                        widget.endChangingProgress!();
                      }
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
                          color: colors.scrubColor,
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
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: colors.backgroundColor,
          ),
        );
      }
    } else {
      return Container();
    }
  }
}
