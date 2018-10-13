package com.example.markdownconverter;

import android.content.*;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import com.overzealous.remark.*;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.ActivityLifecycleListener;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.io.*;
import java.lang.Object;
import java.net.*;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.function.*;
import org.jsoup.*;
import org.w3c.dom.Document;

public class MainActivity extends FlutterActivity {
  public static final String PLATFORM = "app.channel.markdown.data";
  public static final String STREAM = "app.channel.shared.data";
  public static final String TAG = "markdown.data";
  public String markdown;
  public String text;
  public String url;


  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    String action = intent.getAction();
    String type = intent.getType();

    if (Intent.ACTION_SEND.equals(action) && type != null) {
      System.out.println(type);
      if ("text/plain".equals(type)) {
        url = intent.getStringExtra(Intent.EXTRA_TEXT);
        System.out.println(url);
      } 
    }
  }


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), PLATFORM).setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("urltomarkdown")) {
          Remark remark = new Remark();
          text = call.argument("url");
          markdown = remark.convert(text);
          if (markdown != null) {
            System.out.println("SENDING RESULT");
            result.success(markdown);
          } else {
            result.error("UNAVAILABLE", "Something happened!", null);
          }
        } else {
          result.notImplemented();
        }
      }
    }); 

    new EventChannel(getFlutterView(), STREAM).setStreamHandler(
      new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object args, final EventChannel.EventSink events) {
            Log.w(TAG, "adding listener");
            onNewIntent(getIntent());
            if (url != null){
              events.success(url);
              url = null;
          }
        }
        @Override
        public void onCancel(Object args) {
            Log.w(TAG, "cancelling listener");
        }
      });
  }
}