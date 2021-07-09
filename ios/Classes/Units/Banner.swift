//
//  Banner.swift
//  adeasy_mopub
//
//  Created by Randy Stiven Valentin on 7/8/21.
//

import Foundation
import MoPubSDK


import Flutter
import Foundation

class AdEasyBannerFactory : NSObject, FlutterPlatformViewFactory {
    let messeneger: FlutterBinaryMessenger
    
    init(messeneger: FlutterBinaryMessenger) {
        self.messeneger = messeneger
    }
    
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AdEasyBannerAd(
            frame: frame,
            viewId: viewId,
            args: args as? [String : Any] ?? [:],
            messeneger: messeneger
        )
    }
    
    //Returns the `FlutterMessageCodec` for decoding the args parameter of `createWithFrame`.
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

 

class AdEasyBannerAd : NSObject, FlutterPlatformView {
    
    private let channel: FlutterMethodChannel
    private let messeneger: FlutterBinaryMessenger
    private let frame: CGRect
    private let viewId: Int64
    private let args: [String: Any]
    private var adView: MPAdView!
    
    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        
        self.args = args
        self.messeneger = messeneger
        self.frame = frame
        self.viewId = viewId
        let channelName = "\(Constants.CHANNEL_BANNER)\(viewId)"
        print("The current value of channelName is \(channelName)")
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messeneger)
        
        super.init()
    }
    
    func view() -> UIView {
        return getBannerAdView() ?? UIView()
    }
    
    fileprivate func dispose() {
        adView?.stopAutomaticallyRefreshingContents()
        adView?.removeFromSuperview()
        adView = nil
        channel.setMethodCallHandler(nil)
    }
    
    fileprivate func getBannerAdView() -> MPAdView? {
        if adView == nil {
            let adUnitId = self.args["unitID"] as? String ?? "ad_unit_id"
            let autoRefresh = self.args["autoRefresh"] as? Bool ?? false
            let height = self.args["height"] as? NSInteger ?? 0
            
            adView = {
                let view: MPAdView = MPAdView(adUnitId: adUnitId)
                view.delegate = self
                if autoRefresh { adView!.startAutomaticallyRefreshingContents() }
                return view
            }()
            adView!.loadAd(withMaxAdSize: getBannerAdSize(height: height))
        }
        return adView
    }
    
    
    fileprivate func getBannerAdSize(height: NSInteger) -> CGSize {
        if height >= 280 {
            return kMPPresetMaxAdSize280Height
        } else if height >= 250 {
            return kMPPresetMaxAdSize250Height
        } else if height >= 90 {
            return kMPPresetMaxAdSize90Height
        } else if height >= 50 {
            return kMPPresetMaxAdSize50Height
        } else {
            return kMPPresetMaxAdSizeMatchFrame
        }
    }
}

extension AdEasyBannerAd: MPAdViewDelegate {
    func viewControllerForPresentingModalView() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        var args:[String:Any] = [:]
        args["unitID"] = view.adUnitId
        args["keywords"] = view.keywords
        channel.invokeMethod(Constants.EVENT_LOAD, arguments: args)
    }

    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        var args:[String:Any] = [:]
        args["unitID"] = view.adUnitId
        args["errorCode"] = error.localizedDescription
        channel.invokeMethod(Constants.EVENT_FAIL, arguments: args)
    }
    
    func willPresentModalView(forAd view: MPAdView!) {
        var args:[String:Any] = [:]
        args["unitID"] = view.adUnitId
        args["keywords"] = view.keywords
        channel.invokeMethod(Constants.EVENT_CLICK, arguments: args)
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        var args:[String:Any] = [:]
        args["unitID"] = view.adUnitId
        args["keywords"] = view.keywords
        channel.invokeMethod(Constants.EVENT_CLOSE, arguments: args)
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        
    }
}
