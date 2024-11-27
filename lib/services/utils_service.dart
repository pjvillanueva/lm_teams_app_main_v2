import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class UtilsService {
  static final UtilsService _singleton = UtilsService._internal();
  factory UtilsService() {
    return _singleton;
  }
  UtilsService._internal();

  String uid() {
    return ObjectId().toString();
  }

  int notifID() {
    var number = pow(2, 31) - 1;
    return Random().nextInt(number.toInt());
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(tempPath + (rng.nextInt(100)).toString() + '.png');

    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<Uint8List> urlToBytes(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    return response.bodyBytes.buffer.asUint8List();
  }

  Color get randomColor {
    // return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
    //     .withOpacity(1.0);
    return Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }

  Future<String> addressFromLocationEvent(LocationEvent? locationEvent) async {
    try {
      if (locationEvent != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            locationEvent.latitude, locationEvent.longitude,
            localeIdentifier: 'en_US');

        if (placemarks.isNotEmpty) {
          return getAddress(placemarks[0]);
        }
        return '';
      }
      return '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  PlatformType getPlatform() {
    if (kIsWeb) {
      return PlatformType.Web;
    } else if (Platform.isIOS) {
      return PlatformType.IOS;
    } else if (Platform.isAndroid) {
      return PlatformType.Android;
    } else if (Platform.isFuchsia) {
      return PlatformType.Fuchsia;
    } else if (Platform.isLinux) {
      return PlatformType.Linux;
    } else if (Platform.isMacOS) {
      return PlatformType.MacOS;
    } else if (Platform.isWindows) {
      return PlatformType.Windows;
    }
    return PlatformType.Unknown;
  }

  bool isWeb() {
    return (getPlatform() == PlatformType.Web);
  }

  bool isMobile() {
    PlatformType platform = getPlatform();
    return (platform == PlatformType.Android ||
        platform == PlatformType.IOS ||
        platform == PlatformType.Fuchsia);
  }

  bool isComputer() {
    PlatformType platform = getPlatform();
    return (platform == PlatformType.Linux ||
        platform == PlatformType.MacOS ||
        platform == PlatformType.Windows);
  }

  Future<bool> get hasInternet async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  String get timeNow {
    var now = DateTime.now();
    return DateFormat.Hms().format(now).toString();
  }

  Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      return false;
    }
  }

  String generateItemCode() {
    Random random = Random();
    String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String firstLetter = letters[random.nextInt(26)];
    String secondLetter = letters[random.nextInt(26)];
    return '$firstLetter$secondLetter';
  }

  double colorToHue(Color color) {
    double hue = 0.0;

    double minVal = color.red.toDouble();
    double maxVal = color.red.toDouble();

    List<double> rgb = [color.red.toDouble(), color.green.toDouble(), color.blue.toDouble()];
    for (var val in rgb) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    if (maxVal == minVal) {
      hue = 0; // achromatic
    } else {
      if (maxVal == rgb[0]) {
        hue = (rgb[1] - rgb[2]) / (maxVal - minVal);
      } else if (maxVal == rgb[1]) {
        hue = 2.0 + (rgb[2] - rgb[0]) / (maxVal - minVal);
      } else {
        hue = 4.0 + (rgb[0] - rgb[1]) / (maxVal - minVal);
      }

      hue *= 60.0;

      if (hue < 0.0) {
        hue += 360.0;
      }
    }

    return hue;
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromSvgAsset(String assetName,
      [Size size = const Size(10, 10)]) async {
    //Load the SVG picture from the asset
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

    Size deviceSize = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;

    final scaleFactor = math.min(
        deviceSize.width / pictureInfo.size.width, deviceSize.height / pictureInfo.size.height);

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();
    final image = rasterPicture.toImageSync(deviceSize.width.toInt(), deviceSize.height.toInt());
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  bool isJsonString(dynamic json) {
    return json.runtimeType == String;
  }

  int distanceBetweenCoords(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000.0;

    lat1 = lat1 * pi / 180;
    lon1 = lon1 * pi / 180;
    lat2 = lat2 * pi / 180;
    lon2 = lon2 * pi / 180;

    // Calculate the differences between coordinates
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Haversine formula
    final a = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;
    return distance.round();
  }
}

String getAddress(Placemark p) {
  String address = '' +
      getString(p.subLocality, false) +
      getString(p.locality, false) +
      getString(p.subAdministrativeArea, false) +
      getString(p.administrativeArea, false) +
      getString(p.country, true);
  return address;
}

getString(String? text, bool isLast) {
  if (text != null && text.isNotEmpty) {
    return text + (isLast ? '' : ', ');
  }
  return '';
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
