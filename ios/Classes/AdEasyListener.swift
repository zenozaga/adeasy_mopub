//
//  AdEasyListener.swift
//  adeasy_mopub
//
//  Created by Randy Stiven Valentin on 7/8/21.
//

import Foundation
import MoPubSDK

public class AdEasyListener: NSObject ,MPInterstitialAdControllerDelegate, MPRewardedVideoDelegate   {
    
    private var on_load: () -> Void ;
    private var on_opened: () -> Void ;
    private var on_closed : () -> Void ;
    private var on_fail: (Error?) -> Void
    private var on_clicked: () -> Void;
    private var on_complete: () -> Void;
    private var on_reward: () -> Void;
    private var on_leave: () -> Void;
    private var on_start: () -> Void;
    
    private var data:Any?;
    
    

    init(
        onLoad:  @escaping () -> Void = {},
        onOpen:  @escaping () -> Void = {},
        onFail:  @escaping (Error?) -> Void = { (error:Error?) in {}()},
        onClose:  @escaping () -> Void = {} ,
        onClicked:  @escaping () -> Void = {},
        onComplete:  @escaping () -> Void = {},
        onReward:  @escaping () -> Void = {},
        onLeave:  @escaping () -> Void = {},
        onStart:  @escaping () -> Void = {}
    ) {
        self.on_load = onLoad
        self.on_closed = onClose
        self.on_fail = onFail
        self.on_clicked = onClicked
        self.on_complete = onComplete
        self.on_reward = onReward
        self.on_opened = onOpen
        self.on_leave = onLeave
        self.on_start = onStart

    }

 
    public func getData() -> Any?{
        return data;
    }
   
    
    public func onLoad(){
        on_load()
    };
    
    public func onOpen(){
        on_opened()
    };
    
    public func onFail(error: Error?){
        on_fail(error)
    };
    
    public func onClicked(){
        on_clicked()

    };
    
    public func onComplete(){
        on_complete()
    };
    
    public func onClose(){
        on_closed()
    };
    
    public func onReward(){
        on_reward()
    };

    public func onLeave(){
        on_leave()
    };
    
    public func onStart(){
        on_start()
    };
    
 
    
    
    public func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        onOpen()
    }
    
    public func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
     }
    
    public func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
     }
    
    public func interstitialDidDisappear(_ interstitial: MPInterstitialAdController!) {
        onClose()
    }
    
    
    public func interstitialWillDisappear(_ interstitial: MPInterstitialAdController!) {
       
    }
    
    public func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
      onLoad()
    }

    public func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
        onClicked()
    }
    
    public func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!, withError error: Error!) {
        onFail(error: error)
    }
    
    public func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        onLoad()
    }
    
    public func rewardedVideoAdDidExpire(forAdUnitID adUnitID: String!) {
    
    }
    public func rewardedVideoAdDidAppear(forAdUnitID adUnitID: String!) {
      onOpen()
    }
    public func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        onClose()
    }
    public func rewardedVideoAdWillAppear(forAdUnitID adUnitID: String!) {
    
    }
    public func rewardedVideoAdWillDisappear(forAdUnitID adUnitID: String!) {
    
    }
    
    public func rewardedVideoAdWillLeaveApplication(forAdUnitID adUnitID: String!) {
        onLeave()
    }
    public func rewardedVideoAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        onClicked()
    }
    
    public func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
       onFail(error: error)
    }
    
    public func rewardedVideoAdDidFailToPlay(forAdUnitID adUnitID: String!, error: Error!) {
        onFail(error: error)
    }
    
    public func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        
        
        var rewardArgs:[String:Any] = [:]
        rewardArgs["amount"] = reward.amount;
        rewardArgs["label"] = reward.debugDescription;
        rewardArgs["success"] = true;

        
        self.data = rewardArgs;
        onReward()
        
    }
    

}
 
