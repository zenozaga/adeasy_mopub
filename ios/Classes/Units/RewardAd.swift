


//
//  Interstitial.swift
//  adeasy_mopub
//
//  Created by Randy Stiven Valentin on 7/9/21.
//

import Foundation
import MoPubSDK

class AdEasyRewardAd: NSObject {
  
    
    
    private let TAG = "AdEasyMoPub > reward > "
    private var channel:FlutterMethodChannel;
    private var result:FlutterResult?;
    
    fileprivate var delegate: MPRewardedVideoDelegate?
    

    
    init(channel:FlutterMethodChannel!) {

        self.channel = channel
 
    }
    
    
    func load(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        if(MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnitID)){
            
            self.sendEvent(event: Constants.EVENT_LOAD,type: Constants.AD_TYPE_REWARD, error: nil,data: nil)
            result(true)
            
        }else{
            self.delegate = AdEasyListener(
                
                onLoad:{
                    
                    self.sendEvent(event: Constants.EVENT_LOAD,type: Constants.AD_TYPE_REWARD, error: nil, data: nil)
                    result(true)
                    
                    MPRewardedVideo.removeDelegate(forAdUnitId: adUnitID)

                    
                },onFail: { (error:Error?) in
                    
                    self.sendEvent(event: Constants.EVENT_FAIL,type: Constants.AD_TYPE_REWARD,error: error,data: nil)

                    result(FlutterError(
                        code: "0000", message: error?.localizedDescription.description, details: ""
                    ))
                    
                    MPRewardedVideo.removeDelegate(forAdUnitId: adUnitID)

                    
                }
            );
            MPRewardedVideo.setDelegate( self.delegate, forAdUnitId: adUnitID)
            
            MPRewardedVideo.loadAd(withAdUnitID: adUnitID, withMediationSettings: nil)
        }
        
    
    }
    
    func show(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        if(MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnitID)){
 
            
            var listener:AdEasyListener!;
            
            listener = AdEasyListener(
                onOpen: {
                    

                    self.sendEvent(event: Constants.EVENT_OPEN, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)
                    result(true)

                    
                    
                }, onFail: { (error:Error?) in
                    
                    
                    self.sendEvent(event: Constants.EVENT_FAIL, type: Constants.AD_TYPE_REWARD,error: error,data: nil)

                    result(FlutterError(
                        code: "0000", message: error?.localizedDescription.description, details: ""
                    ))
                    
                
                    MPRewardedVideo.removeDelegate(forAdUnitId: adUnitID)

                },
                onClose: {
                    
                    self.sendEvent(event: Constants.EVENT_CLOSE, type: Constants.AD_TYPE_REWARD,error: nil,data: listener.getData())
                    MPRewardedVideo.removeDelegate(forAdUnitId: adUnitID)

                },
                onClicked: {

                    self.sendEvent(event: Constants.EVENT_CLICK, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)

                },onReward: {
                    self.sendEvent(event: Constants.EVENT_REWARDE, type: Constants.AD_TYPE_REWARD,error: nil,data: listener.getData())
                    
                },
                onLeave: {
                    self.sendEvent(event: Constants.EVENT_LEAVE, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)
                }
                
            );
            
            MPRewardedVideo.setDelegate(listener, forAdUnitId: adUnitID)
            
            
            let reward = MPRewardedVideo.selectedReward(forAdUnitID: adUnitID)
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            MPRewardedVideo.presentAd(forAdUnitID: adUnitID, from: rootViewController, with: reward)
                    
            
        }else{
            
            self.sendEvent(event: Constants.EVENT_FAIL, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)

            result(FlutterError(
                code: "0000", message: "\(Constants.AD_TYPE_REWARD) is not Loaded", details: ""
            ))
            
            
        }
        
    }
    
    func sendEvent(event:String, type:String?, error:Error?, data:Any?){
        
        var args:[String:Any] =   [:]
        
        args["type"] = type ?? ""
        args["error"] = error?.localizedDescription.description ?? nil
        args["data"] = data ?? nil

        print("\(TAG) event > \(event) > args > \(args)")
        channel.invokeMethod(event, arguments: args)

    }
    
    
}
