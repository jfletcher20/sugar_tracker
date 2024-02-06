import 'package:flutter/cupertino.dart';

mixin Paging<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  int end = 32;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
      setState(() => end += 8);
    }
  }

  List<Widget> paging(List<dynamic> items, Function(BuildContext, dynamic) card) {
    return [
      for (int i = 0; i < (end > items.length ? items.length : end); i++) card(context, items[i]),
    ];
  }

  Widget scrollable(Widget child) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      child: child,
    );
  }
}
