package com.zenozaga.adeasy_mopub

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.mopub.common.MoPub
import com.mopub.common.MoPubReward
import com.mopub.common.SdkConfiguration
import com.mopub.common.logging.MoPubLog
import com.mopub.common.privacy.ConsentDialogListener
import com.mopub.mobileads.MoPubErrorCode
import com.mopub.mobileads.MoPubInterstitial
import com.mopub.mobileads.MoPubRewardedAds
import com.zenozaga.adeasy_mopub.units.AdEasyBanner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** AdeasyMopubPlugin */
class AdeasyMopubPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mContext: Context
  private  var activity: Activity? = null;
  lateinit var pluginBinding:FlutterPlugin.FlutterPluginBinding;
  private  val TAG:String = "AdEasyMoPub > "
  private var  mInterstitial: MoPubInterstitial? = null;





  ////
  ////
  //// Register Banner units
  ///////////////////////////
  private fun registerunits(){


    if(activity != null &&  pluginBinding != null){

      Log.e(TAG,"REGISTERING BANNERS")

      pluginBinding.platformViewRegistry.registerViewFactory(
        Constants.CHANNEL_BANNER,
        AdEasyBanner( pluginBinding.binaryMessenger, activity!!)
      );

    }

  }



  fun initialization(call: MethodCall, result: Result){

    val testMode = call.argument<Boolean>("testMode")
    val adConsent = call.argument<Boolean>("adConsent")
    val adUnitID = call.argument<String>("adUnitID")

    val configBuilder = SdkConfiguration.Builder(adUnitID ?: "")
      .withLogLevel(if (testMode!!) MoPubLog.LogLevel.DEBUG else MoPubLog.LogLevel.NONE)

    if(!MoPub.isSdkInitialized()){

      MoPub.initializeSdk(activity!!, configBuilder.build()) {
        result.success(true)
      }

    }else{
      result.success(true)
    }



  }


  ////
  ////
  //// Interstitial Methods
  //////////////////////////////////

  fun destroyInterstitial(){

    mInterstitial?.interstitialAdListener = null
    mInterstitial?.destroy();
    mInterstitial = null;

  }
  fun setInterstitial(unitID:String?){

    if(unitID?.isEmpty() == false && mInterstitial?.getAdUnitId() == unitID && mInterstitial?.isReady == true){

    }else{

      destroyInterstitial()
      mInterstitial = MoPubInterstitial(activity!!,unitID ?: "");

    }


  }

  fun loadInterstitial(call: MethodCall, result: Result){

    var unitID:String = call.argument<String>("unitID")!!;

    setInterstitial(unitID);

    if(mInterstitial?.isReady == true){

      sendEvent(Constants.EVENT_LOAD,Constants.AD_TYPE_INERSTITIAL,"")
      result.success(true)
      mInterstitial?.interstitialAdListener = null;

    }else{

      mInterstitial?.interstitialAdListener = (object : Listener(){
        override fun onLoad() {

          Log.d(TAG,"Load > Reward ($unitID)" )

          sendEvent(Constants.EVENT_LOAD,Constants.AD_TYPE_INERSTITIAL,"")
          result.success(true)
          mInterstitial?.interstitialAdListener = null;

        }

        override fun onFail(exception: MoPubErrorCode?) {

          Log.d(TAG,"Error > ${Constants.AD_TYPE_INERSTITIAL} $exception $unitID")

          sendEvent(Constants.EVENT_FAIL,Constants.AD_TYPE_INERSTITIAL,"$exception")
          result.error(exception?.intCode.toString(), exception?.name,"")

          destroyInterstitial();

        }
      });

      mInterstitial?.load();

    }

  }

  fun showInterstitial(call: MethodCall, result: Result){

    var unitID:String = call.argument<String>("unitID")!!;

    if(mInterstitial?.isReady == true){

      mInterstitial?.interstitialAdListener = (object : Listener(){
        override fun onOpen() {

          result.success(true)
          sendEvent(Constants.EVENT_OPEN, Constants.AD_TYPE_INERSTITIAL, "")

        }

        override fun onFail(exception: MoPubErrorCode?) {

          Log.d(TAG,"Error > Reward($unitID) > $exception")

          result.error("0001", "$exception","")
          sendEvent(Constants.EVENT_FAIL, Constants.AD_TYPE_INERSTITIAL, "$exception")

          destroyInterstitial();


        }

        override fun onClosed() {


          sendEvent(Constants.EVENT_CLOSE, Constants.AD_TYPE_INERSTITIAL, "", getData())
          destroyInterstitial();


        }


        override fun onClick() {

          sendEvent(Constants.EVENT_CLICK, Constants.AD_TYPE_REWARD, "")

        }

      });

      mInterstitial?.show()


    }else{

      result.error("0001", "reward is not loaded","")

    }

  }

  ////
  ////
  //// Reward Methods
  //////////////////////////////////

  fun loadReward(call: MethodCall, result: Result){

    var unitID:String = call.argument<String>("unitID")!!;

    if(MoPubRewardedAds.hasRewardedAd(unitID)){

      sendEvent(Constants.EVENT_LOAD,Constants.AD_TYPE_REWARD,"")
      result.success(true)

    }else{

      MoPubRewardedAds.setRewardedAdListener(object : Listener(){
        override fun onLoad() {

          Log.d(TAG,"Load > Reward ($unitID)" )

          sendEvent(Constants.EVENT_LOAD,Constants.AD_TYPE_REWARD,"")
          result.success(true)
          MoPubRewardedAds.setRewardedAdListener(null)

        }

        override fun onFail(exception: MoPubErrorCode?) {

          Log.d(TAG,"Error > Reward $exception $unitID")

          sendEvent(Constants.EVENT_FAIL,Constants.AD_TYPE_REWARD,"$exception")
          result.error(exception?.intCode.toString(), exception?.name,"")
          MoPubRewardedAds.setRewardedAdListener(null)

        }
      });

      MoPubRewardedAds.loadRewardedAd(unitID);

    }

  }

  fun showReward(call: MethodCall, result: Result){

    var unitID:String = call.argument<String>("unitID")!!;

    if(MoPubRewardedAds.hasRewardedAd(unitID)){

      MoPubRewardedAds.setRewardedAdListener(object : Listener(){
        override fun onOpen() {

          result.success(true)
          sendEvent(Constants.EVENT_OPEN, Constants.AD_TYPE_REWARD, "")

        }

        override fun onFail(exception: MoPubErrorCode?) {

          Log.d(TAG,"Error > Reward($unitID) > $exception")

          result.error("0001", "$exception","")
          sendEvent(Constants.EVENT_FAIL, Constants.AD_TYPE_REWARD, "$exception")

          MoPubRewardedAds.setRewardedAdListener(null)


        }

        override fun onClosed() {


          sendEvent(Constants.EVENT_CLOSE, Constants.AD_TYPE_REWARD, "", getData())
          MoPubRewardedAds.setRewardedAdListener(null)

        }

        override fun onReward() {
          sendEvent(Constants.EVENT_REWARDE, Constants.AD_TYPE_REWARD, "", getData())
        }

        override fun onClick() {

          sendEvent(Constants.EVENT_CLICK, Constants.AD_TYPE_REWARD, "")

        }

      });

      MoPubRewardedAds.showRewardedAd(unitID)


    }else{

      result.error("0001", "reward is not loaded","")

    }

  }






  ////
  ////
  ////  FLutter Plugin Methods
  //////////////////////////////////


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, Constants.CHANNEL)
    channel.setMethodCallHandler(this)
    pluginBinding = flutterPluginBinding;
    registerunits();

  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }





  ////
  ////
  ////  ActivityAware Methods
  //////////////////////////////////


  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.e(TAG,"onAttachedToActivity")
    this.activity = binding.activity;
    registerunits();

  }


  override fun onDetachedFromActivity() {
    activity = null;
  }


  override fun onDetachedFromActivityForConfigChanges() {  }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { this.activity = binding.activity  }






  //sendEvent to client
  fun sendEvent(event: String?, type: String, errorMessage: String?, data: Any? = null ) {

    val message = MapUtils();
    if (errorMessage != null && !errorMessage.isEmpty()) message.put("error", errorMessage)

    if(data != null){
      message.put("data", data);
    }

    message.put("type", type)


    Log.d(TAG, "Event: $event   Error: $errorMessage");

    if(event != null) activity?.runOnUiThread{
      channel.invokeMethod(event, message.map())
    }

  }






  ////
  ////
  ////  MethodCallHandler Methods
  //////////////////////////////////

  // Call method handler
  override fun onMethodCall(call: MethodCall, result: Result) {

    val method = call.method

    Log.d(TAG, "method: $method")

    when (method) {
      Constants.METHOD_INIT -> {

        initialization(call, result)

      }
      Constants.METHOD_RESUME -> {

        result.success(true)

      }
      Constants.METHOD_PAUSE -> {

        result.success(true)

      }
      Constants.METHOD_SET_TRACK_NETWORK -> {

        result.success(true)

      }
      Constants.METHOD_SET_CONCENT -> {


      }

      Constants.METHOD_SET_USER -> {

        result.success(true)

      }

      Constants.METHOD_GET_ADVERTISER_ID -> {


      }

      Constants.METHOD_SHOW_INTERSTITIAL -> {

        showInterstitial(call,result)

      }
      Constants.METHOD_LOAD_INTERSTITIAL-> {

        loadInterstitial(call,result)

      }
      Constants.METHOD_LOAD_REWARD -> {
        loadReward(call,result)
      }
      Constants.METHOD_SHOW_REWARD -> {
        showReward(call,result)
      }
      Constants.METHOD_LOAD_OFFERSWALL -> {


      }
      Constants.METHOD_SHOW_OFFERSWALL -> {


      }
      else -> {
        result.notImplemented()
      }
    }
  }



}
