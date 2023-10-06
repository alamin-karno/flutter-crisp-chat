package com.alaminkarno.flutter_crisp_chat.config;

import java.util.Map;

public class User {
    public String email = null;
    public String nickName = null;
    public String phone = null;
    public String avatar = null;
    public Company company = null;

    public static User fromJson(Map<String, Object> json) {
        User user = new User();
        if (json.containsKey("email")) {
            Object emailObj = json.get("email");
            if (emailObj != null) {
                user.email = emailObj.toString();
            }
        }
        if (json.containsKey("nickName")) {
            Object nickNameObj = json.get("nickName");
            if (nickNameObj != null) {
                user.nickName = nickNameObj.toString();
            }
        }
        if (json.containsKey("phone")) {
            Object phoneObj = json.get("phone");
            if (phoneObj != null) {
                user.phone = phoneObj.toString();
            }
        }
        if (json.containsKey("avatar")) {
            Object avatarObj = json.get("avatar");
            if (avatarObj != null) {
                user.avatar = avatarObj.toString();
            }
        }
        if (json.containsKey("company")) {
            Object companyrObj = json.get("company");
            if (companyrObj != null) {
                user.company = Company.fromJson((Map<String, Object>) companyrObj);
            }
        }
        return user;
    }

}
