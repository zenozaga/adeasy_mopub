package com.zenozaga.adeasy_mopub

import com.mopub.common.MoPub
import com.mopub.common.MoPubReward
import com.mopub.mobileads.*


abstract  class Listener: MoPubView.BannerAdListener, MoPubInterstitial.InterstitialAdListener,MoPubRewardedAdListener {



     private var data:Any? = null;

     fun getData(): Any? {
          return data;

     }


     ////
     ////
     ////  Methods to use
     ///////////////////////////////


     open fun onOpen() {}
     open fun onClosed() {}
     open fun onLoad() {}
     open fun onFail(exception: MoPubErrorCode?) {}
     open fun onReward() {}
     open fun onClick() {}
     open fun onStart() {}
     open fun onComplete() {}
     open fun onImpression() {}

     override fun onBannerLoaded(p0: MoPubView) {
          onLoad()
     }

     override fun onBannerFailed(p0: MoPubView?, p1: MoPubErrorCode?) {
          onFail(p1)
     }

     override fun onBannerClicked(p0: MoPubView?) {
          onClick()
     }

     override fun onBannerExpanded(p0: MoPubView?) {
          onImpression()
     }

     override fun onBannerCollapsed(p0: MoPubView?) {

     }

     override fun onInterstitialLoaded(p0: MoPubInterstitial?) {

          onLoad()
     }

     override fun onInterstitialFailed(p0: MoPubInterstitial?, p1: MoPubErrorCode?) {
          onFail(p1)
     }

     override fun onInterstitialShown(p0: MoPubInterstitial?) {
          onOpen()
     }

     override fun onInterstitialClicked(p0: MoPubInterstitial?) {
          onClick()
     }

     override fun onInterstitialDismissed(p0: MoPubInterstitial?) {
          onClosed()
     }

     override fun onRewardedAdClicked(adUnitId: String) {
          onClick()
     }

     override fun onRewardedAdClosed(adUnitId: String) {
          onClosed()
     }

     override fun onRewardedAdCompleted(adUnitIds: Set<String?>, reward: MoPubReward) {

          data = MapUtils()
               .put("amount", reward.amount)
               .put("success", reward.isSuccessful)
               .put("label", reward.label)
               .map()


          onReward()
     }

     override fun onRewardedAdLoadFailure(adUnitId: String, errorCode: MoPubErrorCode) {
          onFail(errorCode)
     }

     override fun onRewardedAdLoadSuccess(adUnitId: String) {
          onLoad()
     }

     override fun onRewardedAdShowError(adUnitId: String, errorCode: MoPubErrorCode) {
          onFail(errorCode)
     }

     override fun onRewardedAdStarted(adUnitId: String) {
          onOpen()
     }

}