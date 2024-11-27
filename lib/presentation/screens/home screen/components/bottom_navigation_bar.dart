// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  HomeBottomNavigationBar({Key? key, required this.pageController, required this.selectedItem})
      : super(key: key);

  final PageController pageController;
  int selectedItem;

  @override
  State<HomeBottomNavigationBar> createState() => _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  final List<Map<String, dynamic>> _bottomNavItems = [
    {'icon': const Icon(Icons.dashboard), 'label': 'Entry'},
    {'icon': const Icon(Icons.people), 'label': 'Contacts'},
    {'icon': const Icon(Icons.map), 'label': 'Map'},
    {'icon': const Icon(Icons.trending_up), 'label': 'Statistics'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60.spMin,
        child: BottomNavigationBar(
            elevation: 10.0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            iconSize: 25.0.spMin,
            unselectedFontSize: 12.0.spMin,
            selectedFontSize: 14.0.spMin,
            items: <BottomNavigationBarItem>[
              for (var item in _bottomNavItems)
                BottomNavigationBarItem(icon: item['icon'], label: item['label'])
            ],
            currentIndex: widget.selectedItem,
            onTap: (index) {
              setState(() {
                widget.selectedItem = index;
                widget.pageController.animateToPage(widget.selectedItem,
                    duration: const Duration(milliseconds: 1), curve: Curves.linear);
              });
            }));
  }
}
