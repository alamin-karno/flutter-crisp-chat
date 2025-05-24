package com.alaminkarno.flutter_crisp_chat.config

import java.net.MalformedURLException
import java.net.URL

data class Company(
    val name: String? = null,
    val url: String? = null,
    val companyDescription: String? = null,
    val employment: Employment? = null,
    val geoLocation: Geolocation? = null
) {
    fun toCrispCompany(): im.crisp.client.external.data.Company {
        val companyUrl: URL? = url?.let {
            try {
                URL(it)
            } catch (e: MalformedURLException) {
                // Consider logging this error or handling it as per plugin's error strategy
                null // Or throw a custom exception
            }
        }
        return im.crisp.client.external.data.Company(
            name,
            companyUrl,
            companyDescription,
            employment?.toCrispEmployment(),
            geoLocation?.toCrispGeolocation()
        )
    }
}
