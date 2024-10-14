package com.alaminkarno.flutter_crisp_chat.config;

import java.net.MalformedURLException;
import java.util.Map;

public class Employment {
    public String title = null;
    public String role = null;

    public static Employment fromJson(Map<String, Object> json) {
        Employment employment = new Employment();
        if (json.containsKey("role")) {
            Object roleObj = json.get("role");
            if (roleObj != null) {
                employment.role = roleObj.toString();
            }
        }
        if (json.containsKey("title")) {
            Object titleObj = json.get("title");
            if (titleObj != null) {
                employment.title = titleObj.toString();
            }
        }
        return employment;
    }


    public im.crisp.client.external.data.Employment toCrispEmployment() {
        return new im.crisp.client.external.data.Employment(
                title,
                role
        );
    }
}
