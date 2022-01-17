import 'package:flutter/material.dart';

import '../dict.dart';

abstract class MyPage extends StatefulWidget {
  const MyPage(this.l, this.title, this.body, {Key? key}) : super(key: key);
  final String l;
  final String title;
  final Widget body;

  @override
  PageState createState() => PageState();
}

class PageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(dict[widget.l]![widget.title]!),
      ),
      body: widget.body,
    );
  }
}
