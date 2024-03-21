import Foundation
import Crisp

struct Geolocation {
    let city: String?
    let country: String?
    
    init(city: String?, country: String?) {
        self.city = city
        self.country = country
    }
    
    static func fromJson(_ json: [String: Any]) -> Geolocation {
        return Geolocation(
            city: json["city"] as? String,
            country: json["country"] as? String
        )
    }
    
    func toCrispGeolocation() -> Crisp.Geolocation {
        return Crisp.Geolocation(
            city: city, country: country
        )
    }
}

struct Employment {
    let title: String?
    let role: String?
    
    init(title: String?, role: String?) {
        self.title = title
        self.role = role
    }
    
    static func fromJson(_ json: [String: Any]) -> Employment {
        return Employment(
            title: json["title"] as? String,
            role: json["role"] as? String
        )
    }
    
    func toCrispEmployment() -> Crisp.Employment {
        return Crisp.Employment(
            title: title,
            role: role
        )
    }
}

struct Company {
    let name: String?
    let url: String?
    let companyDescription: String?
    let employment: Employment?
    let geolocation: Geolocation?
    
    init(name: String?, url: String?, companyDescription: String?, employment: Employment?, geolocation: Geolocation?) {
        self.name = name
        self.url = url
        self.companyDescription = companyDescription
        self.employment = employment
        self.geolocation = geolocation
    }
    
    static func fromJson(_ json: [String: Any]) -> Company {
        return Company(
            name: json["name"] as? String,
            url: json["url"] as? String,
            companyDescription: json["companyDescription"] as? String,
            employment: Employment.fromJson(json["employment"] as? [String: Any] ?? [:]),
            geolocation: Geolocation.fromJson(json["geoLocation"] as? [String: Any] ?? [:])
        )
    }
    
    func toCrispCompany() -> Crisp.Company {
        return Crisp.Company(
            name: name,
            url: url == nil ? nil : URL(string: url!),
            companyDescription: companyDescription,
            employment: employment?.toCrispEmployment(),
            geolocation: geolocation?.toCrispGeolocation()
        )
    }
}

struct User {
    let email: String?
    let nickName: String?
    let phone: String?
    let avatar: String?
    let company: Company?
    
    init(email: String?, nickName: String?, phone: String?, avatar: String?, company: Company?) {
        self.email = email
        self.nickName = nickName
        self.phone = phone
        self.avatar = avatar
        self.company = company
    }
    
    static func fromJson(_ json: [String: Any]) -> User {
        return User(
            email: json["email"] as? String,
            nickName: json["nickName"] as? String,
            phone: json["phone"] as? String,
            avatar: json["avatar"] as? String,
            company: Company.fromJson(json["company"] as? [String: Any] ?? [:])
        )
    }
    
}

struct CrispConfig {
    let websiteID: String
    let tokenId: String?
    let sessionSegment: String?
    let user: User?
    
    init(websiteID: String, tokenId: String?,sessionSegment: String?, user: User?) {
        self.websiteID = websiteID
        self.tokenId = tokenId
        self.sessionSegment = sessionSegment
        self.user = user
    }
    
    static func fromJson(_ json: [String: Any]) -> CrispConfig {
        return CrispConfig(
            websiteID: json["websiteId"] as! String,
            tokenId: json["tokenId"] as? String,
            sessionSegment: json["sessionSegment"] as? String,
            user: User.fromJson(json["user"] as? [String: Any] ?? [:])
        )
    }
}
