import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool?> showProminentDisclosureDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
            child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.all(20.spMin),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Image.asset('assets/logo/coloredlogo.png', height: 30.spMin, width: 30.spMin),
                      SizedBox(height: 10.spMin),
                      const Text('Location Permission',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.spMin),
                      Text(
                          'We collect your location data in the background to improve entry recording and enable map features. Your privacy is our priority, and we never share this information with anyone else. You can turn off location tracking anytime. Do you agree to this?',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface, fontSize: 16.0),
                          textAlign: TextAlign.center),
                      Image.asset('assets/logo/event.png', height: 300.spMin, width: 300.spMin),
                      Row(children: [
                        TextButton(
                            child: Text('No thanks',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Theme.of(context).colorScheme.onSurface)),
                            onPressed: () => Navigator.pop(context, false)),
                        const Spacer(),
                        ElevatedButton(
                            child: const Text('Yes, I agree',
                                style: TextStyle(fontSize: 16.0, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary),
                            onPressed: () => Navigator.pop(context, true))
                      ])
                    ]))));
      });
}
