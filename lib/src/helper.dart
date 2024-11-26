/// Extension on [String] that provides utility methods for common validations.
extension HelperExtensions on String? {
  /// Checks if the string represents a valid email address.
  ///
  /// Returns `true` if the string is a valid email address, otherwise `false`.
  bool get isEmail {
    if (this == null) return false;
    // Improved regex for email validation
    RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(this!);
  }

  /// Checks if the string represents a valid URL.
  ///
  /// Returns `true` if the string is a valid URL, otherwise `false`.
  bool get isUrl {
    if (this == null) return false;
    return Uri.parse(this!).isAbsolute;
  }
}
