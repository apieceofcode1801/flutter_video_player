import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../models/m3u8.dart';
import 'package:http/http.dart' as http;

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

Future<List<M3U8pass>> loadM3U8s(String video) async {
  List<M3U8pass> m3u8s = [];
  m3u8s.add(M3U8pass(dataQuality: "Auto", dataURL: video));
  RegExp regExp = RegExp(
    r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
    caseSensitive: false,
    multiLine: true,
  );

  String? m3u8Content;
  if (m3u8Content == null) {
    http.Response response = await http.get(Uri.parse(video));
    if (response.statusCode == 200) {
      m3u8Content = utf8.decode(response.bodyBytes);
    }
  }
  List<RegExpMatch> matches = regExp.allMatches(m3u8Content!).toList();
  debugPrint(
      "--- HLS Data ----\n$m3u8Content \ntotal length: ${m3u8s.length} \nfinish");

  matches.forEach(
    (RegExpMatch regExpMatch) async {
      String quality = (regExpMatch.group(1)).toString();
      String sourceURL = (regExpMatch.group(3)).toString();
      final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
      final netRegex2 = RegExp(r'(.*)\r?\/');
      final isNetwork = netRegex.hasMatch(sourceURL);
      final match = netRegex2.firstMatch(video);
      String url;
      if (isNetwork) {
        url = sourceURL;
      } else {
        debugPrint('$match');
        final dataURL = match!.group(0);
        url = "$dataURL$sourceURL";
        debugPrint("--- hls child url integration ---\nchild url :$url");
      }
      m3u8s.add(M3U8pass(dataQuality: quality, dataURL: url));
    },
  );
  return m3u8s;
}
