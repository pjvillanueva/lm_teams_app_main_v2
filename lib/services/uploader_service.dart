import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lm_teams_app/data/models/image%20models/image_info.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import 'package:path/path.dart';

class UploaderService {
  final _utils = UtilsService();
  final _socket = WebSocketService();
  final _getSignedUrlLambdaEndpoint = 'https://api-v3.tuilder.com/v3/beehiveupload';

  Future<bool> saveImage(ImageObject imageObject) async {
    if (!_socket.isConnected) {
      return false;
    }
    var response =
        await _socket.sendAndWait(Message<ImageObject>("AddProfileImage", data: imageObject));
    return response.success;
  }

  Future<ImageObject?> uploadAndGetImageObj(File? file) async {
    if (file == null) {
      return null;
    }
    final imageStr = await upload(file);
    if (imageStr == null) {
      return null;
    }
    final info = await getImageInfo(imageStr);
    final uri = Uri.parse(imageStr);

    final imageObj = ImageObject(
        id: _utils.uid(),
        name: uri.pathSegments[uri.pathSegments.length - 1],
        width: info.width ?? 100,
        height: info.height ?? 100,
        path: uri.path,
        host: uri.scheme + "://" + uri.host,
        color: info.color,
        luminance: info.luminance,
        blurhash: info.blurhash);
    return imageObj;
  }

  Future<String?> upload(File file) async {
    var url = _getSignedUrlLambdaEndpoint;

    url += '?filename=_' + Uri.encodeComponent(basename(file.path));
    url += '&session=LETeamsApp';
    url += '&key=essZXhohOAwAheyx14rQVcj1X7xn70Uu';

    try {
      var signedUrlResponse = await http.get(Uri.parse(url));
      var responseMap = jsonDecode(signedUrlResponse.body);
      var imagePath = responseMap["key"];
      var signedUrl = Uri.parse(responseMap["url"]);

      await http.put(
        signedUrl,
        headers: {"Content-Type": "image/jpeg"},
        body: await file.readAsBytes(),
      );

      return "https://tuilder.imgix.net/$imagePath";
    } catch (e) {
      print("Error uploading image: e ");
      return null;
    }
  }

  Future<ImageInformation> getImageInfo(String imageStr) async {
    var info = ImageInformation();
    late List<int> vibrantRGB;

    // Get image width and height
    var metaDataRequest = await http.get(Uri.parse(imageStr + '?fm=json'));
    var metaDataResponse = jsonDecode(metaDataRequest.body);
    info.width = metaDataResponse["PixelWidth"];
    info.height = metaDataResponse["PixelHeight"];

    // get image palette
    var paletteRequest = await http.get(Uri.parse(imageStr + '?palette=json'));
    var paletteResponse = jsonDecode(paletteRequest.body);
    var color = paletteResponse["dominant_colors"]["vibrant"];
    color ??= paletteResponse["dominant_colors"]["muted"];
    if (color != null) {
      vibrantRGB = [
        (color["red"] * 255).toInt(),
        (color["green"] * 255).toInt(),
        (color["blue"] * 255).toInt(),
      ];
    }
    info.color = vibrantRGB;
    info.luminance = paletteResponse["average_luminance"];

    // get blurhash
    var blurhashRequest = await http.get(Uri.parse(imageStr + '?w=50&fm=blurhash'));
    info.blurhash = blurhashRequest.body;

    return info;
  }
}
