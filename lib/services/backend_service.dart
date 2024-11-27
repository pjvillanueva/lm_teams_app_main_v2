import 'package:http/http.dart' as http;

class BackendService {
  Uri getUrl(String path) {
    var url = Uri.parse("http://10.0.2.2:1337$path");
    return url;
  }

  Map<String, String> customHeaders = {"content-type": "application/json"};

  talkToServer() async {
    var response = await http.get(getUrl("/"));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
