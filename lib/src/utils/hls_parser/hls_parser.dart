import 'package:flutter_hls_parser/flutter_hls_parser.dart';

import '../dio/dio_client.dart';

class HlsParser {
  final String hlsUrl;

  HlsParser(this.hlsUrl);

  final Dio _dio = DioClient().getBaseDio();

  Future<String?> _getContents() async {
    try {
      final response = await _dio.get(hlsUrl);

      final String? contents = response.data;

      return contents;
    } catch (_) {
      return null;
    }
  }

  Future<List<Uri?>?> getMediaPlaylistUris() async {
    final String? contents = await _getContents();

    if (contents != null) {
      final playList = await HlsPlaylistParser.create()
          .parseString(Uri.parse(hlsUrl), contents) as HlsMasterPlaylist;

      // sort by width
      final mediaPlaylistUris = playList.mediaPlaylistUrls;
      mediaPlaylistUris.sort((a, b) {
        int widthA = int.parse(
            RegExp(r'(\d+)p\.m3u8').firstMatch(a.toString())!.group(1)!);
        int widthB = int.parse(
            RegExp(r'(\d+)p\.m3u8').firstMatch(b.toString())!.group(1)!);
        return widthA.compareTo(widthB);
      });

      // Get last 4 res: 360p, 480p, 720p, 1080p.
      final last4Elements = mediaPlaylistUris.sublist(
          mediaPlaylistUris.length >= 4 ? mediaPlaylistUris.length - 4 : 0);

      return last4Elements;
    }
    return null;
  }
}
