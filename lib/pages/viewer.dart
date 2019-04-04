import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_pics/main.dart';
import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/misc/tools.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewerPage extends StatelessWidget {
  final Picture data;

  final String heroTag;

  ViewerPage(this.data, [this.heroTag = '##']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        onLongPress: () => _onLongPress(context),
        child: PhotoView(
          heroTag: heroTag,
          imageProvider: CachedNetworkImageProvider(data.url),
          loadingChild: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void _onLongPress(BuildContext context) async {
    List<Widget> children = <Widget>[
      ListTile(
        title: Text('保存到相册'),
        onTap: () => Navigator.of(context).pop(C.menu_download),
      ),
    ];
    if (Platform.isAndroid) {
      children.add(ListTile(
        title: Text('设置为壁纸'),
        onTap: () => Navigator.of(context).pop(C.menu_set_wallpaper),
      ));
    }
    int index = await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          children: children,
        );
      },
    );
    if (index == null) return;
    Tools.fetchImage(context, data, index == C.menu_set_wallpaper);
  }
}
