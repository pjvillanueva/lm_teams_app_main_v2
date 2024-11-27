import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFrame extends StatelessWidget {
  const AppFrame(
      {Key? key,
      this.extendBody,
      this.leading,
      this.title,
      this.content,
      this.actions,
      this.floatingActionButton,
      this.bottomNavigationBar,
      this.drawer,
      this.padding})
      : super(key: key);

  final bool? extendBody;
  final Widget? leading;
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        extendBody: extendBody ?? false,
        backgroundColor: Theme.of(context).colorScheme.background,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 50.spMin),
            child: AppBar(
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
                backgroundColor: Theme.of(context).colorScheme.primary,
                centerTitle: true,
                title: Text(title ?? '', style: const TextStyle(color: Colors.white)),
                leading: leading ??
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.0.spMin),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                leadingWidth: 56.0.spMin,
                actions: actions ?? [])),
        body: SafeArea(
            child: Padding(padding: EdgeInsets.all(padding ?? 20.0.spMin), child: content)));
  }
}

class FrameWithTabBars extends StatelessWidget {
  const FrameWithTabBars(
      {Key? key,
      required this.title,
      required this.tabLength,
      required this.tabs,
      required this.tabContents,
      this.floatingActionButton})
      : super(key: key);

  final String title;
  final int tabLength;
  final List<Widget> tabs;
  final List<Widget> tabContents;
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabLength,
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            floatingActionButton: floatingActionButton,
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
                title:
                    Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                bottom: TabBar(
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    tabs: tabs,
                    indicatorColor: Theme.of(context).colorScheme.secondary)),
            body: TabBarView(children: tabContents)));
  }
}
