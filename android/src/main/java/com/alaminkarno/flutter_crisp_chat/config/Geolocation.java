package com.alaminkarno.flutter_crisp_chat.config;

import java.net.MalformedURLException;
import java.util.Map;

public class Geolocation {
    public String city = null;
    public String country = null;

    public static Geolocation fromJson(Map<String, Object> json) {
        Geolocation geolocation = new Geolocation();
        if (json.containsKey("city")) {
            Object cityObj = json.get("city");
            if (cityObj != null) {
                geolocation.city = cityObj.toString();
            }
        }
        if (json.containsKey("country")) {
            Object countryObj = json.get("country");
            if (countryObj != null) {
                geolocation.country = countryObj.toString();
            }
        }
        return geolocation;
    }

    public im.crisp.client.external.data.Geolocation toCrispGeolocation() {
        return new im.crisp.client.external.data.Geolocation(
                city,
                country
        );
    }
}
