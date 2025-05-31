/// Configuration for the Crisp chat SDK.
///
/// This class holds all the necessary settings to initialize and customize the
/// Crisp chat experience.
///
/// {@category Configuration}
class CrispConfig {
  /// The unique identifier for your website on Crisp.
  ///
  /// This ID connects the SDK to your specific Crisp account and website.
  /// Replace with your actual `WEBSITE_ID` from the Crisp dashboard.
  String websiteID;

  /// An optional token identifier for the session.
  ///
  /// This can be used to link sessions across different platforms or devices.
  String? tokenId;

  /// An optional segment name for the session.
  ///
  /// Segments help categorize users or sessions (e.g., "premium-user", "trial").
  String? sessionSegment;

  /// Enables or disables push notifications from Crisp.
  ///
  /// Defaults to `true`. If set to `false`, users will not receive
  /// push notifications for new messages.
  bool enableNotifications;

  /// Optional user information for the session.
  ///
  /// Providing user details can enrich the chat experience and provide
  /// context to your support agents.
  User? user;

  /// Creates a new [CrispConfig] instance.
  ///
  /// @param websiteID The Crisp website ID.
  /// @param tokenId (Optional) A token for the session.
  /// @param sessionSegment (Optional) A segment name for the session.
  /// @param enableNotifications (Optional) Whether to enable notifications. Defaults to `true`.
  /// @param user (Optional) User information.
  CrispConfig({
    required this.websiteID,
    this.tokenId,
    this.sessionSegment,
    this.enableNotifications = true,
    this.user,
  });

  /// Converts this [CrispConfig] object to a JSON map.
  ///
  /// This format is used by the native Crisp SDK.
  ///
  /// @return A map representing the JSON structure of the configuration.
  Map<String, dynamic> toJson() {
    return {
      "websiteId": websiteID,
      "tokenId": tokenId,
      "sessionSegment": sessionSegment,
      "enableNotifications": enableNotifications,
      "user": user?.toJson(),
    };
  }
}

/// Represents user-specific data for Crisp chat.
///
/// This information can be used to personalize the chat experience and
/// provide context to support agents.
///
/// {@category Configuration}
class User {
  /// The user's email address.
  ///
  /// Providing an email helps in identifying the user across sessions.
  final String? email;

  /// The user's nickname or display name.
  final String? nickName;

  /// The user's phone number.
  final String? phone;

  /// The URL of the user's avatar image.
  ///
  /// This image will be displayed in the Crisp chat interface.
  final String? avatar;

  /// Information about the user's company.
  final Company? company;

  /// Creates a new [User] instance.
  ///
  /// @param email (Optional) The user's email.
  /// @param nickName (Optional) The user's nickname.
  /// @param phone (Optional) The user's phone number.
  /// @param avatar (Optional) URL to the user's avatar.
  /// @param company (Optional) The user's company details.
  User({
    this.email,
    this.nickName,
    this.phone,
    this.avatar,
    this.company,
  });

  /// Converts this [User] object to a JSON map.
  ///
  /// This format is used by the native Crisp SDK.
  ///
  /// @return A map representing the JSON structure of the user data.
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "nickName": nickName,
      "phone": phone,
      "avatar": avatar,
      "company": company?.toJson(),
    };
  }
}

/// Represents company-specific data for a Crisp user.
///
/// {@category Configuration}
class Company {
  /// The name of the company.
  String? name;

  /// The URL of the company's website.
  ///
  /// Example: `https://company.com`
  String? url;

  /// A description of the company.
  String? companyDescription;

  /// Employment details of the user within the company.
  final Employment? employment;

  /// The geolocation of the company.
  final GeoLocation? geoLocation;

  /// Creates a new [Company] instance.
  ///
  /// @param name (Optional) The company's name.
  /// @param url (Optional) The company's website URL.
  /// @param companyDescription (Optional) A description of the company.
  /// @param employment (Optional) User's employment details.
  /// @param geoLocation (Optional) Company's geolocation.
  Company({
    this.name,
    this.url,
    this.companyDescription,
    this.employment,
    this.geoLocation,
  });

  /// Converts this [Company] object to a JSON map.
  ///
  /// This format is used by the native Crisp SDK.
  ///
  /// @return A map representing the JSON structure of the company data.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "url": url,
      "companyDescription": companyDescription,
      "employment": employment?.toJson(),
      "geoLocation": geoLocation?.toJson(),
    };
  }
}

/// Represents employment details of a user.
///
/// {@category Configuration}
class Employment {
  /// The job title of the user (e.g., "Software Engineer").
  String? title;

  /// The role of the user within the company (e.g., "Lead Developer").
  String? role;

  /// Creates a new [Employment] instance.
  ///
  /// @param title (Optional) The user's job title.
  /// @param role (Optional) The user's role.
  Employment({
    this.title,
    this.role,
  });

  /// Converts this [Employment] object to a JSON map.
  ///
  /// This format is used by the native Crisp SDK.
  ///
  /// @return A map representing the JSON structure of the employment data.
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "role": role,
    };
  }
}

/// Represents geolocation data.
///
/// {@category Configuration}
class GeoLocation {
  /// The city name.
  String? city;

  /// The country name.
  String? country;

  /// Creates a new [GeoLocation] instance.
  ///
  /// @param city (Optional) The city name.
  /// @param country (Optional) The country name.
  GeoLocation({this.city, this.country});

  /// Converts this [GeoLocation] object to a JSON map.
  ///
  /// This format is used by the native Crisp SDK.
  ///
  /// @return A map representing the JSON structure of the geolocation data.
  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "country": country,
    };
  }
}
