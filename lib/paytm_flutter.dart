import 'dart:async';

import 'package:flutter/services.dart';

class PaytmFlutter {
  static const MethodChannel _channel =
      const MethodChannel('paytm_flutter');

  static Future<String> get goToPaytm async {
    final String version = await _channel.invokeMethod('goToPaytm',{'aaa':111});
    return version;
  }
}
