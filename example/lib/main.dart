import 'package:adeasy_mopub/adeasy_mopub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdEasyMopubWidget(),
    );
  }
}

class AdEasyMopubWidget extends StatefulWidget {
  @override
  _AdEasyMopubWidgetState createState() => _AdEasyMopubWidgetState();
}

class _AdEasyMopubWidgetState extends State<AdEasyMopubWidget> {

  static const String REWARD_UNIT_ID = "920b6145fb1546cf8b5cf2ac34638bb7";
  static const String INTERSTITIAL_UNIT_ID = "24534e1901884e398f1253216226017e";
  static const String BANNER_UNIT_ID = "b195f8dd8ded45fe847ad89ed1d016da";
  static const String BANNER_RECTANGLE_UNIT_ID = "252412d5e9364a05ab77d9396346d73d";

  bool ready = false;
  bool rewardLoaded = false;
  bool interstitialLoaded = false;
  bool offerWallLoaded = false;
  bool showBanner = false;

  AdEasyBannerSize bannerSize = AdEasyBannerSize.BANNER;
  AdEasyBannerSize bannerSizeRectangle = AdEasyBannerSize.RECTANGLE;
  late Size size;

  ////
  ////
  ////  SHOW ALERT
  ///////////////////////////////
  void alert({required String title, required List<Widget> body}) {

    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: body,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  ////
  ////
  ////  Interstitial
  ///////////////////////////////
  void loadInterstitial() async {
    AdEasyMopub.instance.loadInterstitial(INTERSTITIAL_UNIT_ID).then((value) {
      if (value) {
        setState(() {
          interstitialLoaded = true;
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  void showInterstitial() async {
    AdEasyMopub.instance.showInterstitial(INTERSTITIAL_UNIT_ID, AdEasyListener(onClose: () {
      setState(() {
        interstitialLoaded = false;
      });
    }));
  }

  ////
  ////
  ////  Reward
  ///////////////////////////////
  void loadReward() async {
    AdEasyMopub.instance.loadRewarded(REWARD_UNIT_ID).then((value) {
      if (value) {
        setState(() {
          rewardLoaded = true;
        });
      }
    }).catchError((error) {
      rewardLoaded = false;
      print(error);
    });
  }

  void showReward() async {


    AdEasyListener? listener;
    listener = AdEasyListener(onClose: () {


      setState(() {
        rewardLoaded = false;
      });


      //// Getting rewarded Data


      if (listener!.hasData()) {

        print(listener.getData());

        alert(
            title: "Reward Details",
            body:[
              Text("amount:${listener.get("amount")}"),
              Text("success:${listener.get("success")}"),
              Text("label:${listener.get("label")}")
            ]

        );
      }



    }, onReward: (data) {

      print("rewarded data $data");

    });

    AdEasyMopub.instance.showRewarded(REWARD_UNIT_ID,listener);
  }


  ////
  ////  INIT AdEasyMopub
  ///////////////////////
  Future<void> initAdEasyMopub() async {

    await AdEasyMopub.instance.init(
      testMode: true,
      adUnitID: INTERSTITIAL_UNIT_ID
    );

    setState(() {
      ready = true;
    });

  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AdEasyMopub Plugin'),
      ),
      body: ready
          ? Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                                    ListTile(
                      title: Text("Interstitial Ad".toUpperCase()),
                      trailing: ElevatedButton(
                        child: Text(interstitialLoaded ? "Show" : "Load"),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith(
                                    (states) => interstitialLoaded
                                    ? Colors.deepPurple
                                    : Colors.blueAccent)),
                        onPressed: () {
                          setState(() {
                            if (interstitialLoaded) {
                              showInterstitial();
                            } else {
                              loadInterstitial();
                            }
                          });
                        },
                      )),
                  ListTile(
                    title: Text("Reward Ad".toUpperCase()),
                    trailing: ElevatedButton(
                      child: Text(rewardLoaded ? "Show" : "Load"),
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.resolveWith(
                                  (states) => rewardLoaded
                                  ? Colors.deepPurple
                                  : Colors.blueAccent)),
                      onPressed: () {
                        setState(() {
                          if (rewardLoaded) {
                            showReward();
                          } else {
                            loadReward();
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: size.width,
              child: Column(
                children: [
                  Container(
                      width: bannerSizeRectangle.width.toDouble(),
                      height: bannerSizeRectangle.height.toDouble(),
                      color: Colors.grey,
                      child: AdEasyBannerAd(
                        unitID: BANNER_RECTANGLE_UNIT_ID,
                        size: bannerSizeRectangle,
                      ),
                    ),
                  SizedBox(
                    height: size.height * .05,
                  ),
                  Container(
                    width: bannerSize.width.toDouble(),
                    height: bannerSize.height.toDouble(),
                    color: Colors.grey,
                    child: AdEasyBannerAd(
                      unitID: BANNER_UNIT_ID,
                      size: bannerSize,
                    ),
                  ),
                   SizedBox(
                    height: size.height * .05,
                  )
                ],
              ),
            )
          ],
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initAdEasyMopub();
  }
}
