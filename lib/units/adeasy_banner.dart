
import 'dart:io';

import 'package:adeasy_mopub/adeasy_banner_size.dart';
import 'package:adeasy_mopub/adeasy_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class AdEasyBannerAd extends StatefulWidget {

  static const String TAG = "AdEasyBanner > ";

  final Key? key;
  final AdEasyListener? listener;
  final bool keepAlive;
  final AdEasyBannerSize size;
  final String unitID;

  AdEasyBannerAd({
    this.key,
    this.listener,
    this.keepAlive = false,
    required this.size,
    required this.unitID
  }) : super(key: key);

  @override
  _AdEasyBannerAdState createState() => _AdEasyBannerAdState();
}

class _AdEasyBannerAdState extends State<AdEasyBannerAd> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if(Platform.isIOS){


      return UiKitView(
        key: UniqueKey(),
        viewType: Constants.CHANNEL_BANNER,
        onPlatformViewCreated: _onBannerAdViewCreated,
        creationParams: <String, dynamic>{
          "unitID": widget.unitID,
          "height": widget.size.height,
          "width": widget.size.width,
        },
        creationParamsCodec: StandardMessageCodec(),
      );

    }else if(Platform.isAndroid){

      return AndroidView(
        key: UniqueKey(),
        viewType: Constants.CHANNEL_BANNER,
        onPlatformViewCreated: _onBannerAdViewCreated,
        creationParams: <String, dynamic>{
          "unitID": widget.unitID,
          "height": widget.size.height,
          "width": widget.size.width,
        },
        creationParamsCodec: StandardMessageCodec(),
      );

    }else{

      return SizedBox.shrink();

    }

  }

  void _onBannerAdViewCreated(int id) async {

    final channel = MethodChannel('${Constants.CHANNEL_BANNER}$id');

    channel.setMethodCallHandler((MethodCall call) async {

      var args = call.arguments;

      print("${AdEasyBannerAd.TAG} method: ${call.method} args:$args");

      switch(call.method){

        case Constants.EVENT_LOAD:{
          widget.listener?.onLoad!();
          break;
        }


        case Constants.EVENT_FAIL:{
          widget.listener?.onFail!(Exception(args["error"]?? ""));
          break;
        }

        case Constants.EVENT_CLICK:{
          widget.listener?.onClick!();
          break;
        }

        case Constants.EVENT_CLOSE:{
          widget.listener?.onClose!();
          break;
        }

        case Constants.EVENT_COMPLETE:{
          widget.listener?.onComplete!();
          break;
        }

        default:{

        }

      }

    });

  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
