package com.zenozaga.adeasy_mopub.units

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.mopub.mobileads.MoPubErrorCode
import com.mopub.mobileads.MoPubView
import com.zenozaga.adeasy_mopub.Constants
import com.zenozaga.adeasy_mopub.Listener
import com.zenozaga.adeasy_mopub.MapUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdEasyBanner internal constructor(
    private val messenger: BinaryMessenger,
    val mActivity: Activity
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any): PlatformView {
        return AdEasyBannerView(context, id, args, messenger, mActivity)
    }

}


internal class AdEasyBannerView(
    context: Context,
    id: Int,
    args: Any,
    messenger: BinaryMessenger?,
    activity: Activity
) :
    PlatformView {

    private val adView: FrameLayout
    private val TAG = "AdEasyMoPub > Banner > "
    private val channel: MethodChannel
    private val args: Any
    private val context: Context
    private val activity: Activity
    private lateinit var mAdLayout: MoPubView;


    private fun getBannerSize(args: Any): MoPubView.MoPubAdSize {

        var height:Int =  MoPubView.MoPubAdSize.HEIGHT_50.toInt();

        if(MapUtils.isMap(args)){
            val _h =  MapUtils.getIn(args,"height");
            if(_h != null){
                height = _h as Int;
            }
        }


        Log.e(TAG, "Banner > height > $height")

        if (height >= MoPubView.MoPubAdSize.HEIGHT_280.toInt() ) {
            return MoPubView.MoPubAdSize.HEIGHT_280;
        }else if (height >= MoPubView.MoPubAdSize.HEIGHT_250.toInt() ) {
            return MoPubView.MoPubAdSize.HEIGHT_250;
        } else if (height >= MoPubView.MoPubAdSize.HEIGHT_90.toInt()) {
            return  MoPubView.MoPubAdSize.HEIGHT_90;
        } else if (height >=  MoPubView.MoPubAdSize.HEIGHT_50.toInt()) {
            return  MoPubView.MoPubAdSize.HEIGHT_50
        }

        return  MoPubView.MoPubAdSize.HEIGHT_50;

    }









    init {

        channel = MethodChannel(messenger, Constants.CHANNEL_BANNER + id)

        this.args = args
        this.context = context
        this.activity = activity

        adView = FrameLayout(activity)

        val size = getBannerSize(args)
        mAdLayout = MoPubView(activity);
        mAdLayout.adSize = size;
        mAdLayout.setAdUnitId(MapUtils.getIn(args,"unitID") as String);

        mAdLayout.bannerAdListener = object : Listener(){
            override fun onClick() {

            }

            override fun onLoad() {
                sendEvent(Constants.EVENT_LOAD, null);
            }

            override fun onFail(exception: MoPubErrorCode?) {
                sendEvent(Constants.EVENT_FAIL, "Code=${exception?.intCode} Message=${exception?.name}");
            }

            override fun onImpression() {
                sendEvent(Constants.EVENT_OPEN, null);
            }

            override fun onClosed() {
                sendEvent(Constants.EVENT_CLOSE, null);
            }
        }

        loadBanner()

    }





    private fun loadBanner() {
        if (adView.childCount > 0) adView.removeAllViews()

        val layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        );

        adView.addView(
            mAdLayout, 0, layoutParams
        )
        adView.visibility = View.VISIBLE
        mAdLayout.loadAd()


    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        adView.visibility = View.INVISIBLE
        mAdLayout.bannerAdListener = null;
        mAdLayout.destroy()
        channel.setMethodCallHandler(null)
    }




    //sendEvent to client
    fun sendEvent(event: String?,  errorMessage: String?, data: Any? = null ) {

        val message = MapUtils.getInstance();
        if (errorMessage != null && !errorMessage.isEmpty()) message.put("error", errorMessage)

        if(data != null){
            message.put("data", data);
        }


        if(event != null) activity?.runOnUiThread{
            channel.invokeMethod(Constants.AD_TYPE_BANNER, message.map())
        }

    }



}
