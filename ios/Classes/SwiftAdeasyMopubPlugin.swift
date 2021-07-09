import Flutter
import UIKit
import MoPubSDK
import AppTrackingTransparency
import AdSupport

public class SwiftAdeasyMopubPlugin:  AdEasyListener, FlutterPlugin {
    
    private var mInterstitial:MPInterstitialAdController?;
    private var channel:FlutterMethodChannel;
    private let TAG:String = "AdeasyMoPub > "
    private var interstialManager:AdEasyInterstitial!
    private var rewardManager:AdEasyRewardAd!
    private var viewController:UIViewController?

    fileprivate var delegate: AdEasyListener?

 
    public  init(channel:FlutterMethodChannel) {
    
        self.channel = channel;
        self.interstialManager = AdEasyInterstitial(channel: channel);
        self.rewardManager = AdEasyRewardAd(channel: channel)
        self.viewController =  UIApplication.shared.keyWindow?.rootViewController

    
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
    
    func consentStatus() -> String {
        
        if #available(iOS 14, *) {
        
            let status = ATTrackingManager.trackingAuthorizationStatus;
            
            
            switch status {
            case ATTrackingManager.AuthorizationStatus.authorized:
                return "granted"
            case ATTrackingManager.AuthorizationStatus.denied:
                return "denied"
            case ATTrackingManager.AuthorizationStatus.notDetermined:
                return "notDetermined"
            case ATTrackingManager.AuthorizationStatus.restricted:
                return "restricted"
            @unknown default:
                return "unknown"
            }
            
           
        }else{
            
            return "granted";
            
        }
 
        
    }
 
    
    func setConsent(call: FlutterMethodCall, result: @escaping FlutterResult, withResult:Bool! = true){
  
            
        if #available(iOS 14, *) {
        
            let state = ATTrackingManager.trackingAuthorizationStatus;
            
            print("\(TAG) > status > \(state == .notDetermined)")

            if(state == .notDetermined){
                
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        
                        MoPub.sharedInstance().grantConsent()
                        if(withResult) {
                            result(true);
                        }
                        break;
                    
                    default:
                        if(withResult){
                            result(false)
                        }
                    }
                }
                
            }else if(state == .authorized){
                
                MoPub.sharedInstance().grantConsent()
                if(withResult){
                    result(true)
                }
            }else if(state == .denied || state == .restricted){
                
                MoPub.sharedInstance().revokeConsent()
                
                if(withResult){
                
                    result(false)
                }
                
            }
            
           
        
        }else{
            
            MoPub.sharedInstance().grantConsent()
            
            if(withResult){
                result(true)
            }

            
        }

           
      
        
    }
    
    func initialization(call: FlutterMethodCall, result: @escaping FlutterResult){

 
        let args = call.arguments as? [String : Any] ?? [:]

        let testMode:Bool = args["testMode"] as? Bool ?? false
        let adConsent:Bool = args["adConsent"] as? Bool ?? false
        let adUnitID:String = args["adUnitID"] as? String ?? ""

        if(adConsent){
            self.setConsent(call: call, result: result, withResult: false)
        }
       
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID )
               sdkConfig.loggingLevel = testMode ? .debug : .none
               
               MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
                
         
                
                result(true)
               
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

        case Constants.METHOD_SET_CONCENT:
            self.setConsent(call: call, result: result)
            break;
            
        case Constants.METHOD_GET_ADVERTISER_ID:
            result("\(ASIdentifierManager.shared().advertisingIdentifier)")
            break;

            
        default:
            result(FlutterMethodNotImplemented)
        }
  
    }
    
    
    
    public override func onLoad() {
        print("ya cargue mmgv klk tu dice");
    }
}

 
