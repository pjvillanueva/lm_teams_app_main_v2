import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../logic/blocs/connectivity_bloc.dart';

class ConnectivityIndicator extends StatefulWidget {
  const ConnectivityIndicator({Key? key}) : super(key: key);

  @override
  _ConnectivityIndicatorState createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ColorTween _colorTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _colorTween = ColorTween(
      begin: Colors.green[600],
      end: Colors.green[800],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(builder: (context, state) {
      if (state is DisconnectedState) {
        _controller.reset();
        _colorTween = ColorTween(
          begin: Colors.red,
          end: Colors.red,
        );
      } else {
        _controller.repeat(reverse: true);
        _colorTween = ColorTween(begin: Colors.green[400], end: Colors.green[600]);
      }
      return Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(state is ConnectedState ? 'Connected' : 'Disconnected',
            style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
        SizedBox(width: 5.0.spMin),
        AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                  width: 10.0.spMin,
                  height: 10.0.spMin,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0.spMin),
                      color: _colorTween.evaluate(_controller),
                      boxShadow: [
                        BoxShadow(
                            color: _colorTween.evaluate(_controller)?.withOpacity(0.8) ??
                                (state is ConnectedState ? Colors.green[200] : Colors.red) ??
                                Colors.red,
                            blurRadius: 50.spMin,
                            spreadRadius: -10)
                      ]));
            })
      ]));
    });
  }
}
