//
//  Constants.swift
//  adeasy_mopub
//
//  Created by Randy Stiven Valentin on 7/8/21.
//

import Foundation

struct Constants {
    
      static var CHANNEL = "com.zenozaga/adeasy_mopub";
      static var CHANNEL_BANNER = "com.zenozaga/adeasy_mopub/banner";


      //// Ad Types
      static var  AD_TYPE_INERSTITIAL = "interstitial";
      static var  AD_TYPE_REWARD = "reward";
      static var  AD_TYPE_BANNER = "banner";
      static var  AD_TYPE_OFFERWALL = "offerwall";

      //// Ad Events
      static var  EVENT_FAIL = "failed";
      static var  EVENT_LOAD = "loaded";
      static var  EVENT_OPEN = "opened";
      static var  EVENT_CLOSE = "closed";
      static var  EVENT_CLICK = "clicked";
      static var  EVENT_REWARDE = "rewarded";
      static var  EVENT_COMPLETE = "completed";
      static var  EVENT_START = "start";
      static var  EVENT_LEAVE = "leaved";
      static var  EVENT_IMPRESSION = "impression";
      static var  EVENT_END = "ended";

      //// Ad methods

      static var  METHOD_INIT = "init";
      static var  METHOD_PAUSE = "pause";
      static var  METHOD_RESUME = "resume";
      static var  METHOD_SET_USER = "setUser";
      static var  METHOD_SET_CONCENT = "setConsent";
      static var  METHOD_SET_TEST_MODE = "testMode";
      static var  METHOD_SET_DEBUG_MODE = "debugMode";
      static var  METHOD_SET_TRACK_NETWORK = "trackNetwork";
      static var  METHOD_GET_ADVERTISER_ID = "getAdvertiserId";


      static var  METHOD_LOAD_REWARD = "loadReward";
      static var  METHOD_SHOW_REWARD = "showReward";

      static var  METHOD_LOAD_OFFERSWALL = "loadOffersWall";
      static var  METHOD_SHOW_OFFERSWALL = "showOffersWall";

      static var  METHOD_LOAD_INTERSTITIAL = "loadInterstitial";
      static var  METHOD_SHOW_INTERSTITIAL = "showInterstitial";
}
