import 'dart:async';

import 'package:flutter/services.dart';

class PaytmFlutter {
  static const MethodChannel _channel =
      const MethodChannel('paytm_flutter');

  static Future<String> goToPaytmWithParams(Map map) async{
    final String version = await _channel.invokeMethod('goToPaytm',map);
    return version;
  }

  static Future<String> get goToPaytm async {
    final String version = await _channel.invokeMethod('goToPaytm');
    return version;
  }
}
