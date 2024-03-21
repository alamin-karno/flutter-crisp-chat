package com.alaminkarno.flutter_crisp_chat.config;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

public class Company {
    public String name = null;
    public String url = null;
    public String companyDescription = null;
    public Employment employment = null;
    public Geolocation geolocation = null;


    public static Company fromJson(Map<String, Object> json) {
        Company company = new Company();
        if (json.containsKey("name")) {
            Object nameObj = json.get("name");
            if (nameObj != null) {
                company.name = nameObj.toString();
            }
        }
        if (json.containsKey("url")) {
            Object urlObj = json.get("url");
            if (urlObj != null) {
                company.url = urlObj.toString();
            }
        }
        if (json.containsKey("companyDescription")) {
            Object companyDescriptionObj = json.get("companyDescription");
            if (companyDescriptionObj != null) {
                company.companyDescription = companyDescriptionObj.toString();
            }
        }
        if (json.containsKey("employment")) {
            Object employmentObj = json.get("employment");
            if (employmentObj != null) {
                company.employment = Employment.fromJson((Map<String, Object>) employmentObj);
            }
        }
        if (json.containsKey("geoLocation")) {
            Object geolocationObj = json.get("geoLocation");
            if (geolocationObj != null) {
                company.geolocation = Geolocation.fromJson((Map<String, Object>) geolocationObj);
            }
        }
        return company;
    }

    public im.crisp.client.data.Company toCrispCompany() {
        java.net.URL companyUrl = null;
        if(url != null){
            try {
                companyUrl = new java.net.URL(url);
            } catch (MalformedURLException e) {
                throw new RuntimeException(e);
            }
        }
        return new im.crisp.client.data.Company(
                name,
                companyUrl,
                companyDescription,
                employment == null ? null : employment.toCrispEmployment(),
                geolocation == null ? null : geolocation.toCrispGeolocation()
        );
    }
}
