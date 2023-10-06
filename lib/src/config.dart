/// This class is used to convert Crisp data to JSON format.
class CrispConfig {
  String websiteID;
  String? tokenId;
  User? user;

  CrispConfig({
    required this.websiteID,
    this.tokenId,
    this.user,
  });

  /// Used to convert to JSON format.
  Map<String, dynamic> toJson() {
    return {
      "websiteId": websiteID,  // It will appear as "websiteId" in the JSON.
      "tokenId": tokenId,
      "user": user?.toJson(),
    };
  }
}

/// This class is used to convert User data to JSON format.
class User {
  /// It is important that it is in email format
  final String? email;
  final String? nickName;
  final String? phone;
  final String? avatar;
  final Company? company;

  User({
    this.email,
    this.nickName,
    this.phone,
    this.avatar,
    this.company,
  });

  /// Used to convert to JSON format.
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

/// This class is used to convert Company data to JSON format.
class Company {
  String? name;
  /// It is important that it is in url format
  String? url;
  String? companyDescription;
  Employment? employment;
  Geolocation? geolocation;
  
  Company({
    this.name,
    this.url,
    this.companyDescription,
    this.employment,
    this.geolocation,
  });

  /// Used to convert to JSON format.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "url": url,
      "companyDescription": companyDescription,
      "employment": employment?.toJson(),
      "geolocation": geolocation?.toJson(),
    };
  }
}

/// This class is used to convert Employment data to JSON format.
class Employment {
  String? title;
  String? role;

  Employment({
    this.title,
    this.role,
  });

  // Used to convert to JSON format.
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "role": role,
    };
  }
}

/// This class is used to convert Geolocation data to JSON format.
class Geolocation {
  String? city;
  String? country;

  Geolocation({
    this.city,
    this.country,
  });

  /// Used to convert to JSON format.
  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "country": country,
    };
  }
}
