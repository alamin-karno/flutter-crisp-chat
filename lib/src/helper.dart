/// Extension on [String] that provides utility methods for common validations.
extension HelperExtensions on String? {
  /// Checks if the string represents a valid email address.
  ///
  /// Returns `true` if the string is a valid email address, otherwise `false`.
  bool get isEmail {
    if (this == null) return true;
    RegExp regex = RegExp(r'\w+@\w+\.\w+');
    return regex.hasMatch(this!);
  }

  /// Checks if the string represents a valid URL.
  ///
  /// Returns `true` if the string is a valid URL, otherwise `false`.
  bool get isUrl {
    if (this == null) return true;
    return Uri.parse(this!).isAbsolute;
  }
}
