package com.coder.sharethings;

import android.content.Context;
import android.net.wifi.WifiManager;

import java.lang.reflect.Method;

public class HotPostManager {

    public static final String TAG = "ApManager";
    private final WifiManager mWifiManager;
    private Context context;

    public HotPostManager(Context context) {
        this.context = context;
        mWifiManager = (WifiManager) this.context.getSystemService(Context.WIFI_SERVICE);
    }
    //check whether wifi hotspot on or off
    public boolean isApOn() {
        try {
            Method method = mWifiManager.getClass().getDeclaredMethod("isWifiApEnabled");
            method.setAccessible(true);
            return (Boolean) method.invoke(mWifiManager);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
