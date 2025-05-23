package com.alaminkarno.flutter_crisp_chat.config

data class Employment(
    val title: String? = null,
    val role: String? = null
) {
    fun toCrispEmployment(): im.crisp.client.external.data.Employment {
        return im.crisp.client.external.data.Employment(
            title,
            role
        )
    }
}
