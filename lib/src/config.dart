/// This class represents the configuration for the Crisp chat system.
///
/// Use this class to convert Crisp configuration data to JSON format for integration with the Crisp SDK.
///
/// - [websiteID]: The ID of your website. Replace it with your WEBSITE_ID.
/// - [tokenId]: Assigns the next session with a tokenID.
/// - [sessionSegment]: Assigns a session segment name for more information.
/// - [enableNotifications]: Enable notification for your site. by default it's true.
/// - [user]: Represents user information.
class CrispConfig {
  String websiteID;
  String? tokenId;
  String? sessionSegment;
  bool enableNotifications;
  User? user;

  CrispConfig({
    required this.websiteID,
    this.tokenId,
    this.sessionSegment,
    this.enableNotifications = true,
    this.user,
  });

  /// Converts the configuration to a JSON format.
  ///
  /// Returns a JSON representation of the Crisp configuration.
  Map<String, dynamic> toJson() {
    return {
      "websiteId": websiteID, // Appears as "websiteId" in the JSON.
      "tokenId": tokenId,
      "sessionSegment": sessionSegment,
      "enableNotifications": enableNotifications,
      "user": user?.toJson(),
    };
  }
}

/// This class represents user information for Crisp chat.
///
/// Use this class to convert user data to JSON format for integration with the Crisp SDK.
class User {
  /// The user's email address.
  final String? email;

  /// The user's nickname.
  final String? nickName;

  /// The user's phone number.
  final String? phone;

  /// The URL of the user's avatar image.
  final String? avatar;

  /// The user's company information.
  final Company? company;

  User({
    this.email,
    this.nickName,
    this.phone,
    this.avatar,
    this.company,
  });

  /// Converts user information to JSON format.
  ///
  /// Returns a JSON representation of the user information.
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

/// This class represents company information for Crisp chat.
///
/// Use this class to convert company data to JSON format for integration with the Crisp SDK.
class Company {
  String? name;

  /// The URL of the company's website.
  String? url;

  /// A description of the company.
  String? companyDescription;

  /// The employment details of the company.
  final Employment? employment;

  /// The geolocation of the company.
  final GeoLocation? geoLocation;

  Company({
    this.name,
    this.url,
    this.companyDescription,
    this.employment,
    this.geoLocation,
  });

  /// Converts company information to JSON format.
  ///
  /// Returns a JSON representation of the company information.
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

/// This class represents employment details for Crisp chat.
///
/// Use this class to convert employment data to JSON format for integration with the Crisp SDK.
class Employment {
  /// The job title of the employee.
  String? title;

  /// The role of the employee.
  String? role;

  Employment({
    this.title,
    this.role,
  });

  /// Converts employment details to JSON format.
  ///
  /// Returns a JSON representation of the employment details.
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "role": role,
    };
  }
}

/// This class represents geoLocation information for Crisp chat.
///
/// Use this class to convert geoLocation data to JSON format for integration with the Crisp SDK.
class GeoLocation {
  /// The city where the user is located.
  String? city;

  /// The country where the user is located.
  String? country;

  GeoLocation({this.city, this.country});

  /// Converts geoLocation information to JSON format.
  ///
  /// Returns a JSON representation of the geoLocation information.
  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "country": country,
    };
  }
}
