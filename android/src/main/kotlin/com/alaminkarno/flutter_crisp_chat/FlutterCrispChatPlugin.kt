package com.alaminkarno.flutter_crisp_chat

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.alaminkarno.flutter_crisp_chat.config.* // Import Kotlin data classes
import im.crisp.client.ChatActivity
import im.crisp.client.Crisp
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterCrispChatPlugin */
class FlutterCrispChatPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val CHANNEL_NAME = "flutter_crisp_chat"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "openCrispChat" -> {
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as? HashMap<String?, Any?>
                if (args != null) {
                    val config = parseCrispConfig(args)
                    // Initialize the Crisp SDK with the essential website ID.
                    // This must be called before any other Crisp SDK functions.
                    Crisp.configure(context, config.websiteId)
                    // Apply additional user and session data to the Crisp SDK.
                    setCrispData(config)
                    openActivity()
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Arguments are missing for openCrispChat", null)
                }
            }
            "resetCrispChatSession" -> {
                Crisp.resetChatSession(context)
            }
            
            "setSessionString" -> {
                val args = call.arguments as HashMap<String?, Any?>
                if (args != null) {
                    val key = args["key"] as String
                    val value = args["value"] as String
                    Crisp.setSessionString(key, value)
                }
            }

            "setSessionInt" -> {
                val args = call.arguments as HashMap<String?, Any?>
                if (args != null) {
                    val key = args["key"] as String
                    val value = args["value"] as Int
                    Crisp.setSessionInt(key, value)
                }
            }

            "getSessionIdentifier" -> {
                val sessionId = Crisp.getSessionIdentifier(context)
                if (sessionId != null) {
                    result.success(sessionId)
                } else {
                    result.error("NO_SESSION", "No active session found", null)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun setCrispData(config: CrispConfig) {
        config.tokenId?.let {
            // Sets a token ID for the session, useful for session continuity.
            Crisp.setTokenID(it)
        }
        config.sessionSegment?.let {
            // Assigns a segment to the session for categorization (e.g., "users", "leads").
            Crisp.setSessionSegment(it)
        }
        config.user?.let { user ->
            // Sets the user's nickname.
            user.nickName?.let { Crisp.setUserNickname(it) }
            // Sets the user's email address.
            user.email?.let { Crisp.setUserEmail(it) }
            // Sets the URL for the user's avatar.
            user.avatar?.let { Crisp.setUserAvatar(it) }
            // Sets the user's phone number.
            user.phone?.let { Crisp.setUserPhone(it) }
            // Sets company information for the user.
            user.company?.let { Crisp.setUserCompany(it.toCrispCompany()) }
        }
    }

    private fun openActivity() {
        val intent = Intent(context, ChatActivity::class.java)
        if (activity != null) {
            activity?.startActivity(intent)
        } else {
            // FLAG_ACTIVITY_NEW_TASK is required to start an Activity from a non-Activity
            // context, such as the application context provided by FlutterPluginBinding
            // when the plugin is initialized without a foreground activity.
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // Helper parsing functions
    private fun parseCrispConfig(args: HashMap<String?, Any?>): CrispConfig {
        val websiteId = args["websiteId"] as String
        val tokenId = args["tokenId"] as? String
        val sessionSegment = args["sessionSegment"] as? String
        val enableNotifications = args["enableNotifications"] as? Boolean ?: true

        @Suppress("UNCHECKED_CAST")
        val userMap = args["user"] as? HashMap<String?, Any?>
        val user = userMap?.let { parseUser(it) }

        return CrispConfig(
            websiteId = websiteId,
            tokenId = tokenId,
            sessionSegment = sessionSegment,
            enableNotifications = enableNotifications,
            user = user
        )
    }

    private fun parseUser(userMap: HashMap<String?, Any?>): User {
        val email = userMap["email"] as? String
        val nickName = userMap["nickName"] as? String
        val phone = userMap["phone"] as? String
        val avatar = userMap["avatar"] as? String

        @Suppress("UNCHECKED_CAST")
        val companyMap = userMap["company"] as? HashMap<String?, Any?>
        val company = companyMap?.let { parseCompany(it) }

        return User(
            email = email,
            nickName = nickName,
            phone = phone,
            avatar = avatar,
            company = company
        )
    }

    private fun parseCompany(companyMap: HashMap<String?, Any?>): Company {
        val name = companyMap["name"] as? String
        val url = companyMap["url"] as? String
        val companyDescription = companyMap["companyDescription"] as? String

        @Suppress("UNCHECKED_CAST")
        val employmentMap = companyMap["employment"] as? HashMap<String?, Any?>
        val employment = employmentMap?.let { parseEmployment(it) }

        @Suppress("UNCHECKED_CAST")
        val geolocationMap = companyMap["geoLocation"] as? HashMap<String?, Any?>
        val geolocation = geolocationMap?.let { parseGeolocation(it) }

        return Company(
            name = name,
            url = url,
            companyDescription = companyDescription,
            employment = employment,
            geoLocation = geolocation
        )
    }

    private fun parseEmployment(employmentMap: HashMap<String?, Any?>): Employment {
        val title = employmentMap["title"] as? String
        val role = employmentMap["role"] as? String
        return Employment(title = title, role = role)
    }

    private fun parseGeolocation(geolocationMap: HashMap<String?, Any?>): Geolocation {
        val city = geolocationMap["city"] as? String
        val country = geolocationMap["country"] as? String
        return Geolocation(city = city, country = country)
    }
}