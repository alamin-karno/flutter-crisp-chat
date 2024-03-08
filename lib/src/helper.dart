extension HelperExtensions on String? {
  bool get isEmail {
    if (this == null) return true;
    RegExp regex = RegExp(r'\w+@\w+\.\w+');
    return regex.hasMatch(this!);
  }

  bool get isUrl {
    if (this == null) return true;
    return Uri.parse(this!).isAbsolute;
  }
}
