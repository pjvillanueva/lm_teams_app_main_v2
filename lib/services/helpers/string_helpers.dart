extension StringHelpers on String {
  String get cleanUp {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  double get toDouble => double.tryParse(this) ?? 0.0;
}
