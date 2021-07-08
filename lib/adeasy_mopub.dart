
import 'dart:async';

//// Exporting
export 'package:adeasy_mopub/adeasy_listener.dart';
export 'package:adeasy_mopub/units/adeasy_banner.dart';
export 'package:adeasy_mopub/adeasy_banner_size.dart';


import 'package:adeasy_mopub/adeasy_listener.dart';
import 'package:flutter/services.dart';
import 'constants.dart';


class AdEasyMopub {

  static AdEasyMopub? _instance;
  final MethodChannel methodChannel = MethodChannel(Constants.CHANNEL);
  static const  String TAG = "AdEasyMoPub > APP > ";

  AdEasyListener? _listener;


  AdEasyMopub(){

    print("init method");
    methodChannel.setMethodCallHandler(_handler);

  }

  Future _handler (MethodCall call) async {

    var method = call.method;
    var args = call.arguments;

    print("$TAG method:$method  args: $args");

    switch(method){

      case Constants.EVENT_LOAD:{
        _listener?.onLoad!();
        break;
      }


      case Constants.EVENT_FAIL:{
        _listener?.onFail!(Exception(args["error"]?? ""));
        break;
      }

      case Constants.EVENT_CLICK:{
        _listener?.onClick!();
        break;
      }

      case Constants.EVENT_CLOSE:{
        _listener?.onClose!();
        break;
      }

      case Constants.EVENT_COMPLETE:{
        _listener?.onComplete!();
        break;
      }

      case Constants.EVENT_REWARDE:{
        _listener?.setData(args["data"] ?? args);
        _listener?.onReward!( _listener?.getData());
        break;
      }

      case Constants.EVENT_START:{
        _listener?.onStart!();
        break;
      }

      case Constants.EVENT_LEAVE:{
        _listener?.onLeave!();
        break;
      }

      case Constants.EVENT_IMPRESSION:{
        _listener?.onLeave!();
        break;
      }


      default:{

      }

    }


  }


  Future<bool> init({ String? adUnitID, bool testMode = false, bool adConsent = false}) async {

    var result = await methodChannel.invokeMethod(Constants.METHOD_INIT,{
      "testMode":testMode,
      "adConsent": adConsent,
      "adUnitID": adUnitID ?? ""
    });

    return result;

  }

  Future<void> setConcent({required String userID }) async {

    await methodChannel.invokeMethod(Constants.METHOD_SET_CONCENT,{
      "userID":userID,
    });

  }

  Future<void> pause({required String userID }) async {
    await methodChannel.invokeMethod(Constants.METHOD_PAUSE,{ });
  }


  Future<void> resume() async {
    await methodChannel.invokeMethod(Constants.METHOD_RESUME,{ });
  }


  Future<void> shouldTrackNetworkState({required bool state}) async {
    await methodChannel.invokeMethod(Constants.METHOD_SET_TRACK_NETWORK,{
      "state": state
    });
  }

  Future<String> getAdvertiserID() async {

    return await methodChannel.invokeMethod(Constants.METHOD_GET_ADVERTISER_ID,{ });

  }

  Future<bool> loadInterstitial(String unitID, [AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_LOAD_INTERSTITIAL, {
      "unitID": unitID
    });

    return result;

  }


  Future<bool> showInterstitial(String unitID, [AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_SHOW_INTERSTITIAL, {
      "unitID": unitID
    });

    return result;

  }

  Future<bool> loadRewarded(String unitID, [AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_LOAD_REWARD, {
      "unitID": unitID
    });

    return result;

  }

  Future<bool> showRewarded(String unitID, [AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_SHOW_REWARD, {
      "unitID": unitID
    });

    return result;

  }

  Future<bool> loadOfferWall([AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_LOAD_OFFERSWALL, {});

    return result;

  }


  Future<bool> showOfferWall([AdEasyListener? listener]) async {

    _listener = listener;
    var result = await methodChannel.invokeMethod(Constants.METHOD_SHOW_OFFERSWALL, {});

    return result;

  }

  static AdEasyMopub get instance => _instance ??= AdEasyMopub();

}

