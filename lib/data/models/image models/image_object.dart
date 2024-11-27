import 'package:equatable/equatable.dart';

class ImageObject extends Equatable {
  const ImageObject({
    required this.id,
    required this.path,
    required this.width,
    required this.height,
    this.color,
    this.luminance,
    this.blurhash,
    required this.name,
    this.folder,
    required this.host,
  });

  final String id;
  final String path;
  final int width;
  final int height;
  final List<int>? color;
  final double? luminance;
  final String? blurhash;
  final String name;
  final String? folder;
  final String host;

  @override
  List<Object?> get props =>
      [id, name, width, height, path, host, color, luminance, blurhash, folder];

  get url {
    if (host != "-" && path != "_") {
      return "$host$path";
    }
    return null;
  }

  String get activeMarker {
    return 'https://godisciple.imgix.net/beehive/20210405/xkFyMocn-pin-background.png?blend=' +
        url +
        '%3Fmask64%3DaHR0cHM6Ly90dWlsZGVyLmltZ2l4Lm5ldC9iZWVoaXZlLzIwMjEwNDA0L2NzcWd2aUt6LXBpbi1tYXNrLnBuZw%26w%3D50.7%26h%3D60%26fit%3Dcrop%26fm%3Dpng%26sat%3D0%26con%3D15%26bri%3D12&blend-mode=normal&w=400%h=400&blend-y=0&fm=png';
  }

  get inactiveMarker {
    return 'https://godisciple.imgix.net/beehive/20210405/xkFyMocn-pin-background.png?w=250&h=250&blend=' +
        url +
        '%3Fmask64%3DaHR0cHM6Ly90dWlsZGVyLmltZ2l4Lm5ldC9iZWVoaXZlLzIwMjEwNDA0L2NzcWd2aUt6LXBpbi1tYXNrLnBuZw%26w%3D50.7%26h%3D60%26fit%3Dcrop%26fm%3Dpng%26sat%3D-100%26con%3D15%26bri%3D12&blend-mode=normal&w=66&blend-y=5&fm=png';
  }

  factory ImageObject.fromJson(Map<String, dynamic> json) {
    return ImageObject(
        id: json['id'],
        path: json['path'],
        width: json['width'],
        height: json['height'],
        color: List<int>.from(json['color']),
        luminance: json['luminance'],
        blurhash: json['blurhash'],
        name: json['name'],
        folder: json['folder'],
        host: json['host']);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'width': width,
        'height': height,
        'color': color,
        'luminance': luminance,
        'blurhash': blurhash,
        'name': name,
        'folder': folder,
        'host': host
      };

  @override
  String toString() =>
      'Image Object {id: $id, name: $name, width: $width, height: $height,path: $path, host: $host, color: $color, luminance: $luminance, blurhash: $blurhash, folder: $folder}';
}
