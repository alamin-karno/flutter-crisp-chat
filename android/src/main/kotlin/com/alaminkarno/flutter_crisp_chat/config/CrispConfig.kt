package com.alaminkarno.flutter_crisp_chat.config

data class CrispConfig(
    val websiteId: String,
    val tokenId: String? = null,
    val sessionSegment: String? = null,
    val enableNotifications: Boolean = true,
    val user: User? = null
)
