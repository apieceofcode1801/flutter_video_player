import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

VideoFormat? videoFormat(String url) {
  final a = Uri.parse(url);

  debugPrint("parse url data end : ${a.pathSegments.last}");
  VideoFormat? videoFormat;
  if (a.pathSegments.last.endsWith("mkv")) {
    videoFormat = VideoFormat.dash;
  } else if (a.pathSegments.last.endsWith("mp4")) {
    videoFormat = VideoFormat.other;
  } else if (a.pathSegments.last.endsWith("m3u8")) {
    videoFormat = VideoFormat.hls;
  }
  return videoFormat;
}

double calculateAspectRatio(BuildContext context, Size screenSize) {
  final width = screenSize.width;
  final height = screenSize.height;
  return width > height ? width / height : height / width;
}
