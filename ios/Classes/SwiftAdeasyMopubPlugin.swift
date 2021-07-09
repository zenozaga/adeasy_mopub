import Flutter
import UIKit
import MoPub

public class SwiftAdeasyMopubPlugin:  AdEasyListener, FlutterPlugin {
    
    private var mInterstitial:MPInterstitialAdController?;
    private var channel:FlutterMethodChannel;
    private let TAG:String = "AdeasyMoPub > "
    private var interstialManager:AdEasyInterstitial!
    private var rewardManager:AdEasyRewardAd!

    fileprivate var delegate: AdEasyListener?

 
    public  init(channel:FlutterMethodChannel) {
    
        self.channel = channel;
        self.interstialManager = AdEasyInterstitial(channel: channel);
        self.rewardManager = AdEasyRewardAd(channel: channel)
    
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
  
    let channel = FlutterMethodChannel(name: Constants.CHANNEL, binaryMessenger: registrar.messenger())
    let instance = SwiftAdeasyMopubPlugin(
    channel: channel);

    registrar.addMethodCallDelegate(instance, channel: channel)
    
    registrar.register(
        AdEasyBannerFactory(messeneger: registrar.messenger()),
        withId: Constants.CHANNEL_BANNER)
 
  }
    

    
    func initialization(call: FlutterMethodCall, result: @escaping FlutterResult){

 
        let args = call.arguments as? [String : Any] ?? [:]

        let testMode:Bool = args["testMode"] as? Bool ?? false
        let adConsent:Bool = args["adConsent"] as? Bool ?? false
        let adUnitID:String = args["adUnitID"] as? String ?? ""

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID )
               sdkConfig.loggingLevel = testMode ? .debug : .none
               
               MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
                result(true)
               }


    }

    
    
    func loadReward(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        if(MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnitID)){
            
            self.sendEvent(event: Constants.EVENT_LOAD,type: Constants.AD_TYPE_REWARD,error: nil,data: nil)
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
    
    func showReward(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let args = call.arguments as? [String : Any] ?? [:]
        let adUnitID:String = args["unitID"] as? String ?? ""
        
        if(MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnitID)){
 
            
 
            self.delegate = AdEasyListener(
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
                    
                    self.sendEvent(event: Constants.EVENT_CLOSE, type: Constants.AD_TYPE_REWARD,error: nil,data: self.delegate?.getData())
                    MPRewardedVideo.removeDelegate(forAdUnitId: adUnitID)

                },
                onClicked: {

                    self.sendEvent(event: Constants.EVENT_CLICK, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)

                },onReward: {
                    print("REWARDDDDDDDDDDDDDDDDDDDD")
                    self.sendEvent(event: Constants.EVENT_CLOSE, type: Constants.AD_TYPE_REWARD,error: nil,data: self.delegate?.getData())
                    
                },
                onLeave: {
                    self.sendEvent(event: Constants.EVENT_LEAVE, type: Constants.AD_TYPE_REWARD,error: nil,data: nil)

                }
                
            );
            
            MPRewardedVideo.setDelegate(self.delegate, forAdUnitId: adUnitID)
            
            
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
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
        
        
        
        switch call.method {
        case Constants.METHOD_INIT:
            
            self.initialization(call: call, result: result)
            break;

        case Constants.METHOD_LOAD_INTERSTITIAL:
            self.interstialManager.load(call: call, result: result)
            break;

        case Constants.METHOD_SHOW_INTERSTITIAL:
            self.interstialManager.show(call: call, result: result)
            break;

        case Constants.METHOD_LOAD_REWARD:
            self.rewardManager.load(call: call, result: result)
            break;

        case Constants.METHOD_SHOW_REWARD:
            self.rewardManager.show(call: call, result: result)
            break;

        default:
            result(FlutterMethodNotImplemented)
        }
  
    }
    
    
    
    public override func onLoad() {
        print("ya cargue mmgv klk tu dice");
    }
}

 
