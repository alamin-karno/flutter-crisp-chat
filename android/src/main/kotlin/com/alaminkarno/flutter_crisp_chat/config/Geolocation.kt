package com.alaminkarno.flutter_crisp_chat.config

data class Geolocation(
    val city: String? = null,
    val country: String? = null
) {
    fun toCrispGeolocation(): im.crisp.client.external.data.Geolocation {
        return im.crisp.client.external.data.Geolocation(
            city,
            country
        )
    }
}
