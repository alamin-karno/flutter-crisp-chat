/// Extension on [String] that provides utility methods for common validations.
extension HelperExtensions on String? {
  /// Checks if the string represents a valid email address.
  ///
  /// Returns `true` if the string is a valid email address, otherwise `false`.
  bool get isEmail {
    if (this == null) return false;
    // Standard email regex pattern: checks for a common email structure like 'user@domain.com'.
    // This is a common regex used for basic email format validation.
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
    // Uri.parse().isAbsolute checks if the URI has a scheme (e.g., 'http', 'https')
    // and a host, which is a good indicator of a valid, complete URL.
    // It distinguishes between relative paths and absolute URLs.
    return Uri.parse(this!).isAbsolute;
  }
}
