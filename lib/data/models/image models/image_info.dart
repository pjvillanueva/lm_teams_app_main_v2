class ImageInformation {
  int? width;
  int? height;
  List<int>? color;
  double? luminance;
  String? blurhash;

  ImageInformation(
      {this.width, this.height, this.color, this.luminance, this.blurhash});
  Map toMap() {
    return {
      "width": width,
      "height": height,
      "color": color,
      "luminance": luminance,
      "blurhash": blurhash,
    };
  }
}
