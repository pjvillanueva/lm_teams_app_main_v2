import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100.0.spMin,
                width: 100.0.spMin,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orange.shade900),
                  strokeWidth: 10.0.spMin,
                  color: Colors.orange[900],
                ),
              ),
              SizedBox(
                height: 30.0.spMin,
              ),
              Text(
                'Authenticating...',
                style: TextStyle(color: Colors.white, fontSize: 18.0.spMin),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GenericLoadingScreen extends StatelessWidget {
  const GenericLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ));
  }
}
