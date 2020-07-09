package com.flonger.paytm_flutter;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.paytm.pgsdk.PaytmOrder;
import com.paytm.pgsdk.PaytmPGService;
import com.paytm.pgsdk.PaytmPaymentTransactionCallback;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** PaytmFlutterPlugin */
public class PaytmFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private  Result _result;
  private Context context;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "paytm_flutter");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "paytm_flutter");
    channel.setMethodCallHandler(new PaytmFlutterPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("goToPaytm")) {
      _result = result;
      showPaytm((HashMap) call.arguments);

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void showPaytm(@NonNull HashMap orderMap){
    Log.e("showPaytm: ", orderMap.toString());
    PaytmOrder Order = new PaytmOrder(orderMap);
    PaytmPGService paytmPGService;
    if (BuildConfig.DEBUG){
      // 测试
      paytmPGService = PaytmPGService.getStagingService("");
    }else {
      paytmPGService = PaytmPGService.getProductionService();
    }
    paytmPGService.initialize(Order, null);
    paytmPGService.startPaymentTransaction(getActivity(), true, true, new PaytmPaymentTransactionCallback() {
      @Override
      public void onTransactionResponse(Bundle inResponse) {
        _result.success("success"+inResponse.toString());
      }

      @Override
      public void networkNotAvailable() {
        _result.success("Network connection error: Check your internet connectivity");
      }

      @Override
      public void clientAuthenticationFailed(String inErrorMessage) {
        _result.success("Authentication failed: Server error==" + inErrorMessage);
      }

      @Override
      public void someUIErrorOccurred(String inErrorMessage) {
        _result.success("UI Error " + inErrorMessage);
      }

      @Override
      public void onErrorLoadingWebPage(int iniErrorCode, String inErrorMessage, String inFailingUrl) {
        _result.success("Unable to load webpage==" + inErrorMessage);
      }

      @Override
      public void onBackPressedCancelTransaction() {
        _result.success("Transaction cancelled");
      }

      @Override
      public void onTransactionCancel(String inErrorMessage, Bundle inResponse) {
        _result.success("Cancel"+inErrorMessage);
      }
    });

  }

  public static Activity getActivity() {
    Class activityThreadClass = null;
    try {
      activityThreadClass = Class.forName("android.app.ActivityThread");
      Object activityThread = activityThreadClass.getMethod("currentActivityThread").invoke(null);
      Field activitiesField = activityThreadClass.getDeclaredField("mActivities");
      activitiesField.setAccessible(true);
      Map activities = (Map) activitiesField.get(activityThread);
      for (Object activityRecord : activities.values()) {
        Class activityRecordClass = activityRecord.getClass();
        Field pausedField = activityRecordClass.getDeclaredField("paused");
        pausedField.setAccessible(true);
        if (!pausedField.getBoolean(activityRecord)) {
          Field activityField = activityRecordClass.getDeclaredField("activity");
          activityField.setAccessible(true);
          Activity activity = (Activity) activityField.get(activityRecord);
          return activity;
        }
      }
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    } catch (NoSuchMethodException e) {
      e.printStackTrace();
    } catch (IllegalAccessException e) {
      e.printStackTrace();
    } catch (InvocationTargetException e) {
      e.printStackTrace();
    } catch (NoSuchFieldException e) {
      e.printStackTrace();
    }
    return null;
  }



}
