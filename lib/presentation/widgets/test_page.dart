import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var isSearching = false;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        extendBody: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            title: Text('Test Page',
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: Theme.of(context).colorScheme.onBackground),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [
              Visibility(
                  visible: !isSearching,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                      icon: const Icon(Icons.search)))
            ],
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0.0,
            centerTitle: true),
        body: SafeArea(
            child: SizedBox(
                width: double.infinity,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('H: $height x W: $width'),
                  ElevatedButton(child: const Text('TEST'), onPressed: () async {})
                ]))));
  }
}
