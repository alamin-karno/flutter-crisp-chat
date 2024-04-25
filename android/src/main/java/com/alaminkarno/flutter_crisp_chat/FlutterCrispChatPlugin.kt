package com.alaminkarno.flutter_crisp_chat

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.alaminkarno.flutter_crisp_chat.config.CrispConfig
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
                val args = call.arguments as HashMap<String?, Any?>
                if (args != null) {
                    val config = CrispConfig.fromJson(args)
                    Crisp.configure(context, config.websiteId)
                    setCrispData(config);
                    openActivity()
                } else {
                    result.notImplemented()
                }

            }

            "resetCrispChatSession" -> {
                Crisp.resetChatSession(context)
            }

            else -> result.notImplemented()
        }
    }

    private fun setCrispData(config: CrispConfig) {
        if (config.tokenId != null) {
            Crisp.setTokenID(config.tokenId)
        }
        if (config.sessionSegment != null) {
            Crisp.setSessionSegment(config.sessionSegment)
        }
        if (config.user != null) {
            if (config.user.nickName != null) {
                Crisp.setUserNickname(config.user.nickName)
            }
            if (config.user.email != null) {
                Crisp.setUserEmail(config.user.email)
            }
            if (config.user.avatar != null) {
                Crisp.setUserAvatar(config.user.avatar)
            }
            if (config.user.phone != null) {
                Crisp.setUserPhone(config.user.phone)
            }
            if (config.user.company != null) {
                Crisp.setUserCompany(config.user.company.toCrispCompany())
            }
        }
    }

    private fun openActivity() {
        val intent = Intent(context, ChatActivity::class.java)
        activity?.startActivity(intent) : context.startActivity(intent)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }
}