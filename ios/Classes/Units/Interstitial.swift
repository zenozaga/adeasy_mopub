//
//  Interstitial.swift
//  adeasy_mopub
//
//  Created by Randy Stiven Valentin on 7/9/21.
//

import Foundation
import MoPubSDK

class AdEasyInterstitial: NSObject {
  
    
    
    private var mInterstitial:MPInterstitialAdController?
    private let TAG = "AdEasyMoPub > Interstitial > "
    private var channel:FlutterMethodChannel;
    private var result:FlutterResult?;
    
    fileprivate var ads: [String: MPInterstitialAdController] = [:]
    fileprivate var delegates: [String: MPInterstitialAdControllerDelegate] = [:]
    
    
    init(channel:FlutterMethodChannel!) {

        self.channel = channel
        self.ads = Dictionary<String, MPInterstitialAdController>()

    }

    func destroyInterstitial(unitID:String!){
        
        if(!unitID.isEmpty){
            ads[unitID]?.delegate = nil;
            ads[unitID] = nil;
        }
         
        
    }
    
    func setInterstitial(unitID:String!){
        
        if(!unitID.isEmpty){
            
            let ad = ads[unitID]
            if( ad != nil && ad!.ready == true ){
                
 
            }else{
            
                destroyInterstitial(unitID: unitID)
                ads[unitID] = MPInterstitialAdController(forAdUnitId: unitID)
                
            }
        }
        
    

        
    }

     
    func getInterstitial(unitID:String!) -> MPInterstitialAdController! {
        if(ads[unitID] == nil){
            
            setInterstitial(unitID: unitID)
            return ads[unitID]!
            
        }else{
            return ads[unitID]!
        }
    }
    
    
    public func load(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        let ad = getInterstitial(unitID: adUnitID)
        
        
 
        if(ad?.ready == true){
            
            self.sendEvent(event: Constants.EVENT_LOAD,error: nil,data: nil)
            result(true)
            
        }else{
            
            print("\(TAG) unit > \(adUnitID) \(args)")
 
            delegates[adUnitID] = AdEasyListener(
                onLoad:{
                    
                    self.sendEvent(event: Constants.EVENT_LOAD, error: nil, data: nil)
                    result(true)
                    
                    ad?.delegate = nil;
                    self.delegates[adUnitID] = nil
                    
                },onFail: { (error:Error?) in
                    
                    self.sendEvent(event: Constants.EVENT_FAIL,error: error,data: nil)

                    result(FlutterError(
                        code: "0000", message: error?.localizedDescription.description, details: ""
                    ))
                    
                    ad?.delegate = nil;
                    self.delegates[adUnitID] = nil
                    
                }
            );
 
 
            ad?.delegate = delegates[adUnitID]
            ad?.loadAd()
            
        }

    }

    
    
    
    func show(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        var ad = getInterstitial(unitID: adUnitID)
        
        if(ad?.ready == true){
            
            delegates[adUnitID] = AdEasyListener(
                onOpen: {

                    self.sendEvent(event: Constants.EVENT_OPEN,error: nil,data: nil)
                    result(true)

                }, onFail: { (error:Error?) in
                    
                    self.sendEvent(event: Constants.EVENT_FAIL,error: error,data: nil)

                    result(FlutterError(
                        code: "0000", message: error?.localizedDescription.description, details: ""
                    ))
                    
 
                },
                onClose: {
                    
                    self.sendEvent(event: Constants.EVENT_CLOSE,error: nil,data: nil)
 
                },
                onClicked: {

                    self.sendEvent(event: Constants.EVENT_CLICK,error: nil,data: nil)

                },
                onLeave: {
                    self.sendEvent(event: Constants.EVENT_LEAVE,error: nil,data: nil)

                }
            );
            
      
            ad!.delegate = delegates[adUnitID]
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
              ad!.show(from: rootViewController)
            
        }else{
            
            self.sendEvent(event: Constants.EVENT_FAIL,error: nil,data: nil)

            result(FlutterError(
                code: "0000", message: "\(Constants.AD_TYPE_INERSTITIAL) is not Loaded", details: ""
            ))
            
            self.destroyInterstitial(unitID: "")
        }

    }
    
    
    
    
    
    func sendEvent(event:String, error:Error?, data:Any?){
        
        var args:[String:Any] =   [:]
        
        args["type"] =  Constants.AD_TYPE_INERSTITIAL
        args["error"] = error?.localizedDescription.description ?? nil
        args["data"] = data ?? nil

        print("\(TAG) event > \(event) > args > \(args)")
        channel.invokeMethod(event, arguments: args)

    }
    
    
}
