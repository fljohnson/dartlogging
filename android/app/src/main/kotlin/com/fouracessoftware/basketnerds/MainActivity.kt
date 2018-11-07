package com.fouracessoftware.basketnerds

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel
import android.os.BatteryManager
import android.content.Intent
import android.content.IntentFilter
import android.content.ContextWrapper
import android.content.Context.BATTERY_SERVICE
import android.os.Build.VERSION_CODES
import android.os.Build.VERSION
import android.os.Environment


class MainActivity(): FlutterActivity() {
  private val CHANNEL: String = "com.fouracessoftware.basketnerds/filesys"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            object : MethodCallHandler {
              override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
                var tosend:String = ""
                if(call.method.equals("getExternalDir"))
                {
                  try {
                    tosend = getExternalDir()
                    result.success(tosend)
                  }
                  catch(e:Exception) {
                    tosend = "(no data)"
                    if (e.message != null){
                      tosend = e.message as String
                    }

                    result.error("FAILED",tosend,null)
                  }

                }
                else
                {
                  result.notImplemented()
                }
              }
            })
  }

  private fun getExternalDir(): String {
    val filesilly = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
    val rv:String = filesilly.absolutePath
    return rv
  }
}
