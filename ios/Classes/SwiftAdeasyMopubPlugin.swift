import Flutter
import UIKit
import MoPubSDK

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
        
        switch MoPub.sharedInstance().currentConsentStatus {
        case  MPConsentStatus.consented:
            return "granted"
        case  MPConsentStatus.denied:
            return "denied"
        case  MPConsentStatus.potentialWhitelist:
            return "potentialWhitelist"
        case  MPConsentStatus.doNotTrack:
            return "doNotTrack"
        default:
            return "unknow"
        }
        
    }
    

    func consent(enabled:Bool!){
        
        let isGranted = MoPub.sharedInstance().currentConsentStatus == MPConsentStatus.consented;
        let doNotAsk = MoPub.sharedInstance().currentConsentStatus == MPConsentStatus.doNotTrack;
        let unknow = MoPub.sharedInstance().currentConsentStatus == MPConsentStatus.unknown;

        
        print("\(self.TAG) no muestre nah \(consentStatus()) \(isGranted) \(MoPub.sharedInstance().isGDPRApplicable) \(MoPub.sharedInstance().shouldShowConsentDialog)")
        
    }
    
    func initialization(call: FlutterMethodCall, result: @escaping FlutterResult){

 
        let args = call.arguments as? [String : Any] ?? [:]

        let testMode:Bool = args["testMode"] as? Bool ?? false
        let adConsent:Bool = args["adConsent"] as? Bool ?? false
        let adUnitID:String = args["adUnitID"] as? String ?? ""


       
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID )
               sdkConfig.loggingLevel = testMode ? .debug : .none
               
               MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
                
                if(adConsent){
                    self.consent(enabled: true)
                }
                
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

        default:
            result(FlutterMethodNotImplemented)
        }
  
    }
    
    
    
    public override func onLoad() {
        print("ya cargue mmgv klk tu dice");
    }
}

 
