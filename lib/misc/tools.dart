import 'dart:convert';
import 'dart:io';

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/plugins.dart';
import 'package:daily_pics/widgets/toast.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Tools {
  static Future<File> cacheImage(Picture source) async {
    Uri uri = Uri.parse(source.url);
    String dest = (await getTemporaryDirectory()).path;
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    String filename;
    String s = response.headers.value('Content-Disposition') ?? '';
    if (s.isEmpty) {
      s = source.url;
      filename = s.split('?')[0].substring(s.lastIndexOf('/') + 1);
    } else {
      filename = s.replaceRange(0, s.indexOf('filename=') + 9, '');
    }
    String suffix = filename.substring(filename.lastIndexOf('.'));
    File file = File('$dest/${source.id}$suffix');
    await response.pipe(file.openWrite());
    return file;
  }

  static void safeLaunch(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  static Future<String> fetchText() async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(
      'https://api.lwl12.com/hitokoto/v1?encode=text&charset=utf-8',
    ));
    HttpClientResponse response = await request.close();
    return await response.transform(utf8.decoder).join();
  }

  static Future<void> fetchImage(
    BuildContext context,
    Picture data,
    bool wallpaper,
  ) async {
    try {
      Toast(context, '正在开始下载...').show();
      File file = await Tools.cacheImage(data);
      String path = await Plugins.syncGallery(file);
      Toast(context, '下载完成').show();
      if (!wallpaper) return;
      await Plugins.setWallpaper(File(path));
    } catch (err) {
      Toast(context, '$err').show();
    }
  }

  static Future<void> share(Picture data) async {
    return Share.share('推荐一张图片，「${data.title}」\n图片信息：\n${data.info}\n'
        '查看链接：${data.url}\n来自 Tujian R');
  }
}
