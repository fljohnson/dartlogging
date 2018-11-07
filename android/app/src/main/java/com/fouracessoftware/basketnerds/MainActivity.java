package com.fouracessoftware.basketnerds;

import android.os.Bundle;
import android.os.Environment;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static String CHANNEL = "com.fouracessoftware.basketnerds/filesys";
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                String tosend = "";
                if(call.method.contentEquals("getExternalDir"))
                {
                  try {
                    tosend = getExternalDir();
                    result.success(tosend);
                  }
                  catch(Exception e) {
                  result.error("FAILED",e.getMessage(),null);
                }

                }
                else
                {
                  result.notImplemented();
                }
              }
            });

    /*
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
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
    });
    */
  }

/*
  private fun getExternalDir(): String {
    val filesilly = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
    val rv:String = filesilly.absolutePath
    return rv
  }
  */
private String getExternalDir() {
  File filesilly = Environment.getExternalStoragePublicDirectory("My Documents");
  return filesilly.getAbsolutePath();
}
}
